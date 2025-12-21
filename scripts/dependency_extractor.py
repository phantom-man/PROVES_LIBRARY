#!/usr/bin/env python3
"""
Dependency Extractor with LangSmith Tracing
Extracts dependencies from documentation using LLM with full observability
"""
import os
from typing import List, Dict, Any, Optional
from langsmith import traceable
from langsmith.wrappers import wrap_openai
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


class DependencyExtractor:
    """Extracts dependencies from documentation with LangSmith tracing"""

    def __init__(self):
        """Initialize OpenAI client with LangSmith wrapping"""
        # Wrap OpenAI client to automatically trace all LLM calls
        self.client = wrap_openai(OpenAI())
        self.model = "gpt-4o-mini"

    @traceable(name="extract_dependencies_from_document")
    def extract_dependencies(
        self,
        document_text: str,
        document_name: str,
        document_type: str = "technical_doc"
    ) -> List[Dict[str, Any]]:
        """
        Extract all dependencies from a document

        Args:
            document_text: Full text of the document
            document_name: Name/identifier of the document
            document_type: Type of document (code, doc, config, etc.)

        Returns:
            List of extracted dependencies with metadata
        """
        # First, chunk the document if it's too large
        chunks = self._chunk_document(document_text)

        all_dependencies = []
        for i, chunk in enumerate(chunks):
            chunk_deps = self._extract_from_chunk(
                chunk,
                document_name,
                chunk_index=i,
                total_chunks=len(chunks)
            )
            all_dependencies.extend(chunk_deps)

        # Deduplicate and merge
        merged = self._merge_dependencies(all_dependencies)

        return merged

    @traceable(name="chunk_document")
    def _chunk_document(self, text: str, chunk_size: int = 4000) -> List[str]:
        """
        Split document into chunks for processing

        Args:
            text: Document text
            chunk_size: Maximum characters per chunk

        Returns:
            List of text chunks
        """
        # Simple chunking by character count with paragraph awareness
        paragraphs = text.split('\n\n')
        chunks = []
        current_chunk = ""

        for para in paragraphs:
            if len(current_chunk) + len(para) > chunk_size and current_chunk:
                chunks.append(current_chunk)
                current_chunk = para
            else:
                current_chunk += "\n\n" + para if current_chunk else para

        if current_chunk:
            chunks.append(current_chunk)

        return chunks if chunks else [text]

    @traceable(name="extract_from_chunk")
    def _extract_from_chunk(
        self,
        chunk: str,
        document_name: str,
        chunk_index: int,
        total_chunks: int
    ) -> List[Dict[str, Any]]:
        """
        Extract dependencies from a single chunk using LLM

        Args:
            chunk: Text chunk to process
            document_name: Source document name
            chunk_index: Index of this chunk
            total_chunks: Total number of chunks

        Returns:
            List of dependencies found in this chunk
        """
        system_prompt = """You are a dependency extraction expert for mission-critical CubeSat systems.

Extract ALL dependencies from the provided documentation chunk. For each dependency, identify:

1. **Component** - What component/module/subsystem has the dependency
2. **Depends On** - What it depends on (another component, hardware, data, state, etc.)
3. **Relationship Type** - The ERV type:
   - depends_on: Runtime dependency
   - requires: Build/configuration requirement
   - enables: Makes something possible
   - conflicts_with: Incompatible with
   - mitigates: Reduces risk of
   - causes: Leads to effect
4. **Criticality** - HIGH, MEDIUM, or LOW
5. **Location** - Line numbers or section where found
6. **Source** - How we know this (documentation, code, config, inferred)
7. **Description** - Brief explanation of the dependency

Return ONLY a JSON array of dependencies. Example:
[
  {
    "component": "ImuManager",
    "depends_on": "LinuxI2cDriver",
    "relationship_type": "depends_on",
    "criticality": "HIGH",
    "location": "Line 28",
    "source": "documentation",
    "description": "ImuManager requires I2C driver to communicate with IMU sensor"
  }
]

If no dependencies are found, return an empty array: []
"""

        user_message = f"""Document: {document_name}
Chunk {chunk_index + 1} of {total_chunks}

{chunk}

Extract all dependencies from this chunk."""

        # This LLM call is automatically traced by wrap_openai
        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=0.1,  # Low temperature for consistent extraction
            response_format={"type": "json_object"}
        )

        # Parse the JSON response
        import json
        try:
            content = response.choices[0].message.content
            # Handle if the response is wrapped in a JSON object with a key
            parsed = json.loads(content)
            if isinstance(parsed, dict):
                # If it's a dict, look for common keys like "dependencies", "results", etc.
                for key in ['dependencies', 'results', 'items', 'data']:
                    if key in parsed:
                        dependencies = parsed[key]
                        break
                else:
                    # If no common key, assume it's a single dependency
                    dependencies = [parsed] if parsed else []
            else:
                dependencies = parsed

            # Add metadata
            for dep in dependencies:
                dep['document_name'] = document_name
                dep['chunk_index'] = chunk_index

            return dependencies
        except json.JSONDecodeError as e:
            print(f"Warning: Failed to parse LLM response as JSON: {e}")
            return []

    @traceable(name="merge_dependencies")
    def _merge_dependencies(self, dependencies: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Merge duplicate dependencies and consolidate information

        Args:
            dependencies: List of all extracted dependencies

        Returns:
            Deduplicated and merged dependencies
        """
        # Group by (component, depends_on, relationship_type)
        groups: Dict[tuple, List[Dict[str, Any]]] = {}

        for dep in dependencies:
            key = (
                dep.get('component', ''),
                dep.get('depends_on', ''),
                dep.get('relationship_type', '')
            )
            if key not in groups:
                groups[key] = []
            groups[key].append(dep)

        # Merge each group
        merged = []
        for group_deps in groups.values():
            if not group_deps:
                continue

            # Use first as template
            merged_dep = group_deps[0].copy()

            # Consolidate locations
            locations = []
            for dep in group_deps:
                loc = dep.get('location', '')
                if loc and loc not in locations:
                    locations.append(loc)
            merged_dep['location'] = ', '.join(locations)

            # Use highest criticality
            criticalities = ['HIGH', 'MEDIUM', 'LOW']
            max_criticality = 'LOW'
            for dep in group_deps:
                crit = dep.get('criticality', 'LOW')
                if criticalities.index(crit) < criticalities.index(max_criticality):
                    max_criticality = crit
            merged_dep['criticality'] = max_criticality

            # Combine descriptions
            descriptions = [dep.get('description', '') for dep in group_deps if dep.get('description')]
            merged_dep['description'] = ' | '.join(descriptions) if descriptions else merged_dep.get('description', '')

            merged.append(merged_dep)

        return merged

    @traceable(name="find_cross_document_dependencies")
    def find_cross_document_dependencies(
        self,
        doc1_dependencies: List[Dict[str, Any]],
        doc2_dependencies: List[Dict[str, Any]],
        doc1_name: str,
        doc2_name: str
    ) -> List[Dict[str, Any]]:
        """
        Identify dependencies that span across two documents

        Args:
            doc1_dependencies: Dependencies from first document
            doc2_dependencies: Dependencies from second document
            doc1_name: Name of first document
            doc2_name: Name of second document

        Returns:
            List of cross-document dependencies
        """
        cross_deps = []

        # Find components from doc1 that depend on things defined in doc2
        doc2_components = {dep['component'] for dep in doc2_dependencies}
        doc2_provides = {dep['depends_on'] for dep in doc2_dependencies}

        for dep1 in doc1_dependencies:
            depends_on = dep1.get('depends_on', '')
            # Check if doc1 depends on something that's a component in doc2
            if depends_on in doc2_components or depends_on in doc2_provides:
                cross_deps.append({
                    'from_document': doc1_name,
                    'to_document': doc2_name,
                    'component': dep1['component'],
                    'depends_on': depends_on,
                    'relationship_type': dep1['relationship_type'],
                    'criticality': dep1['criticality'],
                    'description': f"Cross-document: {doc1_name} → {doc2_name}: {dep1.get('description', '')}"
                })

        return cross_deps


@traceable(name="process_document_pipeline")
def process_document_pipeline(
    document_path: str,
    document_name: str
) -> Dict[str, Any]:
    """
    Full pipeline to process a document and extract dependencies

    Args:
        document_path: Path to document file
        document_name: Name/identifier for the document

    Returns:
        Dictionary with extraction results and statistics
    """
    # Read document
    with open(document_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract dependencies
    extractor = DependencyExtractor()
    dependencies = extractor.extract_dependencies(
        document_text=content,
        document_name=document_name
    )

    # Calculate statistics
    stats = {
        'total_dependencies': len(dependencies),
        'by_criticality': {
            'HIGH': len([d for d in dependencies if d.get('criticality') == 'HIGH']),
            'MEDIUM': len([d for d in dependencies if d.get('criticality') == 'MEDIUM']),
            'LOW': len([d for d in dependencies if d.get('criticality') == 'LOW'])
        },
        'by_type': {}
    }

    for dep in dependencies:
        rel_type = dep.get('relationship_type', 'unknown')
        stats['by_type'][rel_type] = stats['by_type'].get(rel_type, 0) + 1

    return {
        'document_name': document_name,
        'dependencies': dependencies,
        'statistics': stats
    }


if __name__ == '__main__':
    import sys

    # Test with trial documents
    if len(sys.argv) > 1:
        doc_path = sys.argv[1]
        doc_name = os.path.basename(doc_path)

        print(f"Processing {doc_name}...")
        result = process_document_pipeline(doc_path, doc_name)

        print(f"\n📊 Extraction Statistics:")
        print(f"  Total dependencies: {result['statistics']['total_dependencies']}")
        print(f"  Criticality breakdown:")
        for level, count in result['statistics']['by_criticality'].items():
            print(f"    {level}: {count}")
        print(f"  Relationship types:")
        for rel_type, count in result['statistics']['by_type'].items():
            print(f"    {rel_type}: {count}")

        print(f"\n✅ Full trace available in LangSmith UI")
    else:
        print("Usage: python dependency_extractor.py <document_path>")
        print("\nExample:")
        print("  python dependency_extractor.py trial_docs/fprime_i2c_driver_full.md")
