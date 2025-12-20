---
entry_id: software-001
type: risk-pattern
domain: software
observed: I2C address conflicts in multi-sensor power monitoring configurations
sources:
  - citation: "PROVES Kit INA219 Power Monitor Issue #31"
    url: "https://github.com/proveskit/fprime-proves/issues/31"
    excerpt: "Multiple INA219 sensors defaulting to same I2C address causing bus conflicts"
  - citation: "F Prime I2C Driver Documentation"
    url: "https://fprime.jpl.nasa.gov/latest/docs/"
    excerpt: "I2C devices must have unique addresses on shared bus"
artifacts:
  - type: component
    path: "github.com/proveskit/fprime-proves/components/I2CManager"
    description: "I2C manager component with multiplexer support"
  - type: test
    path: "github.com/proveskit/fprime-proves/tests/I2C/test_address_conflicts.py"
    description: "Test suite for I2C address conflict detection"
resolution: Use I2C multiplexer (TCA9548A) to create separate bus segments
verification: Run test suite and verify all sensors readable without bus errors
tags:
  - power
  - i2c
  - hardware-integration
  - multiplexer
  - sensors
created: 2024-12-20
updated: 2024-12-20
---

# I2C Address Conflicts in Multi-Device Power Monitoring

## Problem

When multiple INA219 current/voltage sensors are used in a PROVES Kit power monitoring system, they all default to the same I2C address (0x40). This causes bus conflicts where only one sensor can be read at a time, or readings become corrupted.

## Context

University CubeSat teams frequently need to monitor power consumption across multiple subsystems (radio, payload, flight computer, etc.). The INA219 is a common choice for this monitoring, but hardware address selection is limited to only 4 possible addresses via solder jumpers.

When more than 4 INA219 sensors are needed, teams encounter this conflict.

## Resolution

Use the TCA9548A I2C multiplexer to create 8 separate I2C bus segments. Each segment can support devices with duplicate addresses.

**Implementation approach:**
1. Connect all INA219 sensors to TCA9548A channels instead of main I2C bus
2. Create I2CManager component that:
   - Selects appropriate channel before each read
   - Maintains channel state
   - Handles channel switching errors
3. Update power monitoring topology to route through I2CManager

## Code Example

```python
# F Prime component pseudo-code
class I2CManager:
    def select_channel(self, channel: int):
        # Write to TCA9548A control register
        self.i2c_write(MUX_ADDRESS, 1 << channel)

    def read_sensor(self, channel: int, address: int):
        self.select_channel(channel)
        return self.i2c_read(address)
```

## Verification

1. Run I2C scanner on each multiplexer channel
2. Verify each sensor appears on its assigned channel only
3. Run concurrent read test (all sensors simultaneously)
4. Check for no bus errors in telemetry
5. Verify power values match expected ranges

## Lessons Learned

- **Plan I2C addresses early** - Map all devices before hardware selection
- **Budget for multiplexers** - Assume you'll need more sensors than initially planned
- **Test concurrent access** - Race conditions appear under load, not in unit tests
- **Document channel mapping** - Critical for debugging and future modifications

## Related Patterns

- `build-042`: TCA9548A integration guide
- `software-015`: I2C bus error recovery
- `ops-008`: Power monitoring checklist

## Alternative Solutions

**Option 1:** Use different sensor models with unique addresses
- **Pro:** Simpler hardware
- **Con:** Different drivers, inconsistent telemetry format

**Option 2:** Use SPI sensors instead
- **Pro:** No address conflicts
- **Con:** More GPIO pins, faster power consumption

**Option 3:** Time-multiplex sensor reads
- **Pro:** No additional hardware
- **Con:** Slower update rate, complex scheduling

**Recommended:** TCA9548A multiplexer (used by PROVES Kit reference design)

## Real-World Usage

- BroncoSat-2: 4 INA219 sensors via TCA9548A
- University of Hawaii ARTEMIS: 6 sensors across 3 subsystems
- Multiple other PROVES Kit missions

## References

1. TCA9548A Datasheet: [Texas Instruments](https://www.ti.com/product/TCA9548A)
2. INA219 Datasheet: [Texas Instruments](https://www.ti.com/product/INA219)
3. PROVES Kit schematic: [GitHub](https://github.com/proveskit)
4. F Prime I2C Driver: [F Prime Documentation](https://fprime.jpl.nasa.gov/)
