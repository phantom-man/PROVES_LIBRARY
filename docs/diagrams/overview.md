---
layout: default
title: Dependency Overview
---

# Dependency Overview

Complete inventory of all 45+ dependencies found in F´ I2C Driver and PROVES Kit Power Management documentation.

[← Back to Home](../index.html)

---

## F´ I2C Driver Dependencies

### Software Architecture

```mermaid
graph TB
    subgraph "Application Layer"
        APP[Application Components]
    end

    subgraph "Device Manager Layer"
        DM[ImuManager<br/>Device Manager]
        DM_PORTS[Output Ports:<br/>- busWriteRead<br/>- busWrite]
        DM_TYPES[Data Types:<br/>- ImuData<br/>- GeometricVector3]
    end

    subgraph "Bus Driver Layer"
        BD[LinuxI2cDriver<br/>Bus Driver]
        BD_IFACE[Drv.I2c Interface]
        BD_STATUS[Drv.I2cStatus]
    end

    subgraph "Hardware Layer"
        HW[MPU6050 IMU Sensor<br/>I2C Address: 0x68]
        I2C_BUS[I2C Hardware Bus<br/>/dev/i2c-1]
    end

    APP -->|requests data| DM
    DM -->|mirrors interface| BD_IFACE
    DM -->|uses| DM_PORTS
    DM -->|defines| DM_TYPES
    DM -->|port calls| BD
    BD -->|implements| BD_IFACE
    BD -->|returns| BD_STATUS
    BD -->|hardware I/O| I2C_BUS
    I2C_BUS -->|physical connection| HW

    style APP fill:#e1f5ff
    style DM fill:#fff4e1
    style BD fill:#f0e1ff
    style HW fill:#f5f5f5
```

### Configuration Dependencies

```mermaid
graph LR
    subgraph "Build System"
        FPUTIL[fprime-util]
        FPP[FPP Component<br/>Modeling]
    end

    subgraph "Topology Configuration"
        TOPO[topology.fpp]
        CONFIG[configureTopology]
        INST[Component<br/>Instances]
    end

    subgraph "Device Configuration"
        ADDR[I2C Address<br/>0x68]
        REGS[Register Addresses:<br/>RESET_REG: 0x00<br/>CONFIG_REG: 0x01<br/>DATA_REG: 0x10]
        VALS[Register Values:<br/>RESET_VAL: 0x80<br/>DEFAULT_ADDR: 0x48]
    end

    FPUTIL -->|builds| TOPO
    FPP -->|defines| INST
    TOPO -->|contains| INST
    CONFIG -->|sets| ADDR
    ADDR -->|from datasheet| REGS
    REGS -->|configured with| VALS

    style FPUTIL fill:#e8f5e9
    style CONFIG fill:#fff3e0
    style ADDR fill:#fce4ec
```

---

## PROVES Kit Load Switch Dependencies

### Power Control Architecture

```mermaid
graph TB
    subgraph "Load Switch Manager"
        LSM[LoadSwitchManager<br/>Implements LoadSwitchProto]
        SWITCHES{Load Switches}
        STATE[switch_states<br/>Dictionary]
    end

    subgraph "Hardware Controls"
        RADIO[Radio Transceiver<br/>board.RADIO_ENABLE]
        IMU[IMU Sensor<br/>board.IMU_ENABLE]
        MAG[Magnetometer<br/>board.MAG_ENABLE]
        CAM[Camera<br/>board.CAMERA_ENABLE]
    end

    subgraph "Software Dependencies"
        DIO[digitalio.DigitalInOut]
        LOGGER[pysquared.logger.Logger]
        PROTO[LoadSwitchProto<br/>Interface]
        RETRY[with_retries<br/>Decorator]
        ERR[HardwareInitializationError]
    end

    LSM -->|controls| SWITCHES
    LSM -->|tracks state in| STATE
    SWITCHES -->|powers| RADIO
    SWITCHES -->|powers| IMU
    SWITCHES -->|powers| MAG
    SWITCHES -->|powers| CAM

    LSM -->|requires| DIO
    LSM -->|requires| LOGGER
    LSM -->|implements| PROTO
    LSM -->|uses| RETRY
    LSM -->|raises| ERR

    style LSM fill:#e1f5ff
    style RADIO fill:#ffebee
    style IMU fill:#ffebee
    style MAG fill:#ffebee
    style CAM fill:#ffebee
    style DIO fill:#f3e5f5
```

### Configuration Flow

```mermaid
sequenceDiagram
    participant User
    participant LSM as LoadSwitchManager
    participant Pin as DigitalInOut
    participant HW as Hardware

    User->>LSM: Initialize with switches dict
    LSM->>Pin: Create DigitalInOut(board.IMU_ENABLE)
    LSM->>LSM: Set enable_logic (active high/low)
    LSM->>LSM: Initialize switch_states dict

    User->>LSM: turn_on("imu")
    LSM->>Pin: Set pin HIGH (if active high)
    Pin->>HW: Enable power to IMU
    LSM->>LSM: Update switch_states["imu"] = True
    LSM-->>User: Return True (success)

    User->>LSM: get_switch_state("imu")
    LSM->>LSM: Query switch_states dict
    LSM-->>User: Return True (powered)
```

---

## Dependency Statistics

### By Category

| Category | F´ Count | PROVES Kit Count | Total |
|----------|----------|------------------|-------|
| **Software Dependencies** | 9 | 6 | 15 |
| **Hardware Dependencies** | 4 | 5 | 9 |
| **Configuration Dependencies** | 5 | 3 | 8 |
| **Build System Dependencies** | 3 | 0 | 3 |
| **Data Type Dependencies** | 4 | 0 | 4 |
| **State Management Dependencies** | 0 | 3 | 3 |
| **TOTAL** | 25 | 17 | **42** |

### By Criticality

```mermaid
pie title Dependency Criticality Distribution
    "HIGH" : 28
    "MEDIUM" : 11
    "LOW" : 3
```

### By Relationship Type

| Relationship Type | Count | Examples |
|-------------------|-------|----------|
| **requires** | 23 | Device Manager requires Bus Driver |
| **enables** | 7 | Load Switch enables IMU power |
| **depends_on** | 6 | Application depends_on Device Manager |
| **controls** | 5 | LoadSwitchManager controls hardware pins |
| **implements** | 1 | ZephyrI2cDriver implements Drv.I2c |

---

## Source Location Coverage

Every dependency tracked with precise source locations:

### F´ Documentation Coverage
- **File:** `nasa/fprime/docs/how-to/develop-device-driver.md`
- **Lines Analyzed:** 411
- **Dependencies Found:** 25
- **Average Density:** 1 dependency per 16.4 lines

### PROVES Kit Documentation Coverage
- **File:** `proveskit/pysquared/docs/load_switch.md`
- **Lines Analyzed:** 154
- **Dependencies Found:** 17
- **Average Density:** 1 dependency per 9.1 lines

---

## Navigation

- [← Back to Home](../index.html)
- [Next: Cross-System Dependencies →](cross-system.html)

---

**Analysis Method:** Manual annotation with line-by-line review
**Confidence Level:** High (human-verified)
**Date:** December 20, 2024
