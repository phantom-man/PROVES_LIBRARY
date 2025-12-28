# Testing

This directory contains testing scripts, test data, and experimental code for the PROVES Library system.

## Purpose

Use this directory for:
- Test scripts for validating system components
- Integration tests for the curator pipeline
- Performance and load testing utilities
- Test fixtures and sample data
- Experimental features under development

## Structure

### Recommended Organization

- **scripts/** - Test scripts (unit tests, integration tests, validators)
- **data/** - Test data, fixtures, and sample inputs
- **results/** - Test outputs and results (add to .gitignore)
- **docs/** - Testing documentation and guides

## Related Directories

- **testing_data/** - Historical test data and trial documents
- **scripts/archive/** - Archived one-time test scripts
- **production/** - Production-ready code and scripts

## Running Tests

Tests should be run from the project root with the production virtual environment:

```bash
# Activate virtual environment
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # Linux/Mac

# Run test scripts
python testing/scripts/test_name.py
```

## Best Practices

1. **Isolate test data** - Use separate test databases or test tables
2. **Clean up after tests** - Remove test data when complete
3. **Document test purpose** - Clear comments and docstrings
4. **Use production environment** - Test against actual dependencies
5. **Move validated tests** - Production-ready tests go to production/scripts/

---

**Note:** This is for active testing and development. Historical test data is in testing_data/.
