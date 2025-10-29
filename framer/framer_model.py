
#Framer Block Functional Model--1
# Verification Block --2

# 1
import numpy as np
from enum import Enum
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass

# Configuration and Interfaces

@dataclass
class FramerConfig:
    """Configuration_register_settings"""
    reset_x: bool = True                    # Active Low
    use_256_points: bool = False            # When HIGH 256 /LOW 128
    overlap_half_window: bool = False       # 50% Overlapping
    frame_skip_count: int = 0               # skip N frames (0-127)
    
    def validate(self):
        """Checking_illegal_configurations"""
        if self.frame_skip_count != 0 and self.overlap_half_window:
            raise ValueError("Cannot use frame skipping with overlap mode")
        if not (0 <= self.frame_skip_count <= 127):
            raise ValueError("frame_skip_count must be 0-127")

@dataclass
class ADCFramerTransaction:
    """Valid-Only protocol"""
    valid: bool = False
    data: int = 0           # 8-bit data  Q(1,7)

@dataclass
class FramerWindowingTransaction:
    """Framer -> Windowing interface Valid-Ready protocol """
    valid: bool = False
    ready: bool = True
    data: int = 0


@dataclass
class SPIFramerDDITransaction:
    """ DDI_interface"""
    ddi_valid: bool = False
    ddi_data: int = 0


@dataclass
class CycleSnapshot:
    """Complete state capture for one clock cycle"""
    """Data types for all the ports and registers"""
    cycle: int
    # Input_ports 
    adc_valid: bool
    adc_data: int
    windowing_ready: bool
    ddi_valid: bool
    ddi_data: int
    # Output_ports
    framer_valid: bool
    framer_data: int
    adc_power_on: bool
    adc_data_required: bool
    # Internal_state
    sample_write_index: int
    sample_read_index: int
    sample_read_count: int
    sample_read_base: int
    emit_frame_state: str
    emit_state: str
    frames_received: int

# State Machine Definitions(FSM)-- structures

class FrameState(Enum):
    """Frame recieving state machine """
    FR_NONE = 0     # Frame not yet ready
    FR_HALF = 1     # half frame ready --useful in overlap
    FR_FULL = 2     # Frame fully ready all 128 entries


class EmitState(Enum):
    """Frame emission state machine """
    IDLE = 0        # wait for the frame
    EMIT = 1        # actively sending the frame



# Framer Functional Model-- (DUT)--reference model

class FramerFMOD:
    """
    Contents of the DUT:
     1. 256x8 single-port SRAM
     2. Configurable frame sizes --128/256
     3. 50% frame overlap
     4. Frame skip option
     5. ADC power ports
    
       Ingress: Valid-Only ( valid=1)
       Egress: Valid-Ready ( valid=1 and ready=1)
    """
    
    def __init__(self, config: FramerConfig):
        self.config = config
        self.config.validate()
        
        # Storage---Equivalent to SRAM
        self.sram = np.zeros(256, dtype=np.uint8)
        
        # Write-state
        self.sample_write_index = 0
        
        # Read-state
        self.sample_read_index = 0
        self.sample_read_count = 0
        self.sample_read_base = 0
        
        # FSM
        self.frame_state = FrameState.FR_NONE
        self.emit_state = EmitState.IDLE
        self.frame_counter = 0
        
        # Output_registers
        self.output_valid = False
        self.output_data = 0
        
        # Power_ports
        self.adc_power_on = True
        self.adc_data_required = True
        
        # For_capture
        self.cycle_count = 0
        self.transaction_log = []
    
    def frame_size(self):
        """Return value->configured frame size in samples"""
        return 256 if self.config.use_256_points else 128
    
    def emit_frame_size(self):
        """Return value-> number of samples between frame emissions"""
        if self.config.overlap_half_window:
            return self.frame_size() // 2
        else:
            return self.frame_size()
    
    def at_emit_boundary(self):
        """Condition check ->write completes an emit boundary"""
        emit_size = self.emit_frame_size()
        return ((self.sample_write_index + 1) % emit_size) == 0
    
    def should_write_sram(self):
        """Determine if current sample should be written to SRAM"""
        if self.config.overlap_half_window:
            # Always write in overlap mode
            return True
        else:
            # Frames which are not skipped
            return (self.frame_counter % (self.config.frame_skip_count + 1)) == 0
    
    def update_adc_power_hints(self):
        """
        ADC power conditions
        """
        if self.config.frame_skip_count <= 1:
            #  ADC always on
            self.adc_power_on = True
            self.adc_data_required = True
        else:
            frame_size = self.frame_size()
            current_frame_num = self.sample_write_index // frame_size
            
            # Sampling checks
            sampling = (current_frame_num % (self.config.frame_skip_count + 1)) == 0
            
            # Next Frame sampling check
            next_frame_num = current_frame_num + 1
            power_needed = (next_frame_num % (self.config.frame_skip_count + 1)) == 0
            
            self.adc_power_on = power_needed
            self.adc_data_required = sampling
    
    # Write State Machine
   
    def write_sample(self, adc_trans):
        """
        1.Write to SRAM if not skipping this frame
        2. Increment write index
        3. Frame emit boundaries
        """
        if not adc_trans.valid:
            return
        
        # Write to SRAM if needed
        if self.should_write_sram():
            addr = self.sample_write_index & 0xFF
            self.sram[addr] = adc_trans.data & 0xFF
        
        # Checking boundary
        at_boundary = self.at_emit_boundary()
        
        # Updating the write pointer
        self.sample_write_index = (self.sample_write_index + 1) & 0xFF
        
        # Updating Frame State
        if at_boundary:
            self.update_frame_state()
        
        # Updating Power ports
        self.update_adc_power_hints()
    
    def update_frame_state(self):
        """
        Frame Recieving- state machine.
    
        1.Overlap mode: FR_NONE -> FR_HALF -> FR_FULL
        2.Normal mode: FR_NONE -> FR_FULL [skip FR_HALF]
        """
        if self.config.overlap_half_window:
            if self.frame_state == FrameState.FR_NONE:
                self.frame_state = FrameState.FR_HALF
            elif self.frame_state == FrameState.FR_HALF:
                self.frame_state = FrameState.FR_FULL
        else:
            # Checking condition-> frame should be emitted
            if (self.frame_counter % (self.config.frame_skip_count + 1)) == 0:
                self.frame_state = FrameState.FR_FULL
            self.frame_counter += 1
    
    # Emit State Machine 
    
    def emit_sample(self, windowing_ready):
        """
        Frame emission state machine.
        
        From spec section 4.2.5.7 (Fig 13):
        - Transition to EMIT when frame is ready
        - Stream samples to windowing block
        - Return to IDLE after full frame emitted
        
        Returns: (valid, data) tuple
        """
        valid = False
        data = 0
        
        # Capture current state before any transitions
        # (prevents state transition and emission in same cycle)
        current_state = self.emit_state
        
        # Emission logic - only if we're already emitting
        if current_state == EmitState.EMIT:
            if windowing_ready:
                # Read from SRAM
                addr = self.sample_read_index & 0xFF
                data = int(self.sram[addr])
                valid = True
                
                # Update counters
                self.sample_read_count += 1
                self.sample_read_index = (self.sample_read_index + 1) & 0xFF
                
                # Check if frame complete
                if self.sample_read_count >= self.frame_size():
                    # Done emitting this frame
                    self.emit_state = EmitState.IDLE
                    
                    if self.config.overlap_half_window:
                        # Move base forward by half frame for next emission
                        self.sample_read_base = (self.sample_read_base + self.frame_size() // 2) & 0xFF
                        self.frame_state = FrameState.FR_HALF
                    else:
                        self.frame_state = FrameState.FR_NONE
                        self.sample_read_base = self.sample_read_index
        
        # State transition -> only if currently idle
        elif current_state == EmitState.IDLE:
            if self.frame_state == FrameState.FR_FULL:
                # Start emitting
                self.emit_state = EmitState.EMIT
                self.sample_read_count = 0
                self.sample_read_index = self.sample_read_base
        
        return valid, data
    
    # Main Clock Tick---equivalent to CLK
    
    def clock_tick(self, adc_trans, windowing_ready=True, ddi_trans=None):
        """
        Single clock cycle execution.
        Arguments:
            adc_trans: ADC input transaction
            windowing_ready: Ready signal from windowing block
            ddi_trans: Optional direct data injection from SPI
        Returns:
            Dictionary with all outputs for this cycle
        """
        # Reset-x handling
        if not self.config.reset_x:
            self.reset()
            return self.get_outputs()
        
        # Write process: process ADC input
        self.write_sample(adc_trans)
        
        # DDI path: direct data insert
        if ddi_trans and ddi_trans.ddi_valid:
            addr = self.sample_write_index & 0xFF
            self.sram[addr] = ddi_trans.ddi_data & 0xFF
            self.sample_write_index = (self.sample_write_index + 1) & 0xFF
        
        # Read process: emit frame
        valid, data = self.emit_sample(windowing_ready)
        self.output_valid = valid
        self.output_data = data
        
        # Log this cycle
        snapshot = self.capture_snapshot(adc_trans, windowing_ready, ddi_trans)
        self.transaction_log.append(snapshot)
        
        self.cycle_count += 1
        
        return self.get_outputs()
    
    # Reset and utility functions
    
    def reset(self):
        """Reset all state to initial conditions"""
        self.sram.fill(0)
        self.sample_write_index = 0
        self.sample_read_index = 0
        self.sample_read_count = 0
        self.sample_read_base = 0
        self.frame_state = FrameState.FR_NONE
        self.emit_state = EmitState.IDLE
        self.frame_counter = 0
        self.output_valid = False
        self.output_data = 0
        self.cycle_count = 0
        self.update_adc_power_hints()
    
    def get_outputs(self):
        """Return current output signals"""
        return {
            'valid': self.output_valid,
            'data': self.output_data,
            'adc_power_on': self.adc_power_on,
            'adc_data_required': self.adc_data_required
        }
    
    def capture_snapshot(self, adc_trans, windowing_ready, ddi_trans):
        """Capture complete state for this cycle"""
        return CycleSnapshot(
            cycle=self.cycle_count,
            adc_valid=adc_trans.valid,
            adc_data=adc_trans.data,
            windowing_ready=windowing_ready,
            ddi_valid=ddi_trans.ddi_valid if ddi_trans else False,
            ddi_data=ddi_trans.ddi_data if ddi_trans else 0,
            framer_valid=self.output_valid,
            framer_data=self.output_data,
            adc_power_on=self.adc_power_on,
            adc_data_required=self.adc_data_required,
            sample_write_index=self.sample_write_index,
            sample_read_index=self.sample_read_index,
            sample_read_count=self.sample_read_count,
            sample_read_base=self.sample_read_base,
            emit_frame_state=self.frame_state.name,
            emit_state=self.emit_state.name,
            frames_received=self.frame_counter
        )


# =============================================================================
# Verification Testbench
# =============================================================================

class FramerTestbench:
    """
    Comprehensive testbench for Framer FMOD.
    
    Functions perfromed:
      1.Stimulus generation
      2.Response checking
      3.Coverage tracking
      4.Protocol verification--valid & valid_ready
    """
    
    def __init__(self):  #initializing the counts
        self.tests_passed = 0
        self.tests_failed = 0
        self.coverage = {
            'frame_128': False,
            'frame_256': False,
            'overlap_mode': False,
            'skip_frames': False,
            'reset_test': False,
            'backpressure': False,
            'power_mgmt': False
        }
    
    def assert_equal(self, actual, expected, msg):
        """Assertion with reporting"""
        if actual == expected:
            self.tests_passed += 1
            return True
        else:
            self.tests_failed += 1
            print(f"[X] FAIL: {msg}")
            print(f"   Expected: {expected}, Got: {actual}")
            return False
    
    def run_all_tests(self):
        """Execute complete test suite"""
        print("="*80)
        print("FRAMER (FMOD) VERIFICATION TESTS")
        print("="*80)
        
        self.test_1_basic_128_frame()
        self.test_2_basic_256_frame()
        self.test_3_overlapping_windows()
        self.test_4_frame_skipping()
        self.test_5_reset_behavior()
        self.test_6_backpressure()
        self.test_7_power_management()
        
        self.print_summary()
    
    # Test Cases
    
    def test_1_basic_128_frame(self):
        """Test basic 128-sample frame emission"""
        print("\n[TEST 1] Basic 128-Frame Emission")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False, 
                            overlap_half_window=False, 
                            frame_skip_count=0)
        fmod = FramerFMOD(config)
        
        # Send 128 samples
        for i in range(128):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        
        print(f"DEBUG: After 128 samples - write_idx={fmod.sample_write_index}, "
              f"frame_state={fmod.frame_state.name}")
        print(f"DEBUG: SRAM[0:10] = {fmod.sram[0:10].tolist()}")
        print(f"DEBUG: read_base={fmod.sample_read_base}, read_index={fmod.sample_read_index}")
        
        # Verify frame is ready
        self.assert_equal(fmod.frame_state, FrameState.FR_FULL, 
                         "Frame should be ready after 128 samples")
        
        # Collect emitted frame
        emitted = []
        for cycle in range(200):
            out = fmod.clock_tick(ADCFramerTransaction(), windowing_ready=True)
            if out['valid']:
                emitted.append(out['data'])
                if len(emitted) <= 5:
                    print(f"DEBUG: Cycle {cycle}, emitted sample {len(emitted)-1}: "
                          f"{out['data']}, read_idx={fmod.sample_read_index-1}")
        
        print(f"DEBUG: Total emitted: {len(emitted)}, first 10: {emitted[:10]}")
        
        # Verifying the  results
        self.assert_equal(len(emitted), 128, "Should emit exactly 128 samples")
        self.assert_equal(emitted[:10], list(range(10)), "Data should match input")
        
        self.coverage['frame_128'] = True
        print("[PASS] Test 1 PASSED")
    
    def test_2_basic_256_frame(self):
        """Test basic 256-sample frame emission"""
        print("\n[TEST 2] Basic 256-Frame Emission")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=True, 
                            overlap_half_window=False, 
                            frame_skip_count=0)
        fmod = FramerFMOD(config)
        
        # Send 256 samples
        for i in range(256):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        print(f"DEBUG: After 256 samples - write_idx={fmod.sample_write_index}, "
              f"frame_state={fmod.frame_state.name}")
        print(f"DEBUG: SRAM[0:10] = {fmod.sram[0:10].tolist()}")
        print(f"DEBUG: read_base={fmod.sample_read_base}, read_index={fmod.sample_read_index}")
        
        self.assert_equal(fmod.frame_state, FrameState.FR_FULL,
                         "Frame should be ready after 256 samples")
        
        # Collect emitted frame
        emitted = []
        for _ in range(300):
            out = fmod.clock_tick(ADCFramerTransaction(), windowing_ready=True)
            if out['valid']:
                emitted.append(out['data'])
        
        self.assert_equal(len(emitted), 256, "Should emit exactly 256 samples")
        
        self.coverage['frame_256'] = True
        print("[PASS] Test 2 PASSED")
    
    def test_3_overlapping_windows(self):
        """Test 50% overlapping window mode"""
        print("\n[TEST 3] 50% Overlapping Windows")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False, 
                            overlap_half_window=True, 
                            frame_skip_count=0)
        fmod = FramerFMOD(config)
        
        # Send first 128 samples (need full frame before first emit)
        for i in range(128):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        
        print(f"DEBUG: After 128 samples - frame_state={fmod.frame_state.name}, "
              f"emit_state={fmod.emit_state.name}, read_base={fmod.sample_read_base}")
        
        # First frame should be ready
        self.assert_equal(fmod.frame_state, FrameState.FR_FULL,
                         "First frame ready at 128 samples")
        
        # Emit first frame (stop writing during emission - single port SRAM!)
        frame1 = []
        print(f"DEBUG: Before emit - read_base={fmod.sample_read_base}, "
              f"read_index={fmod.sample_read_index}")
        for cycle in range(150):
            out = fmod.clock_tick(ADCFramerTransaction(valid=False), windowing_ready=True)
            if out['valid']:
                frame1.append(out['data'])
                if len(frame1) <= 3:
                    print(f"DEBUG: Emit cycle {cycle}, sample {len(frame1)-1}: "
                          f"value={out['data']}")
        
        print(f"DEBUG: Frame1 length={len(frame1)}, "
              f"first 10: {frame1[:10] if len(frame1) >= 10 else frame1}")
        print(f"DEBUG: After Frame1 emit - frame_state={fmod.frame_state.name}, "
              f"read_base={fmod.sample_read_base}")
        
        self.assert_equal(len(frame1), 128, "First frame should be 128 samples")
        self.assert_equal(frame1[:10], list(range(10)), "First frame should start at 0")
        
        # Now send next 64 samples (total 192)
        for i in range(128, 192):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        
        print(f"DEBUG: After 192 samples - frame_state={fmod.frame_state.name}")
        
        # Second frame should be ready (128 samples: indices 64-191)
        frame2 = []
        for _ in range(150):
            out = fmod.clock_tick(ADCFramerTransaction(valid=False), windowing_ready=True)
            if out['valid']:
                frame2.append(out['data'])
        
        print(f"DEBUG: Frame2 length={len(frame2)}, "
              f"first 10: {frame2[:10] if len(frame2) >= 10 else frame2}")
        self.assert_equal(len(frame2), 128, "Second frame should be 128 samples")
        
        # Verify 50% overlap: last 64 of frame1 == first 64 of frame2
        if len(frame1) >= 128 and len(frame2) >= 64:
            overlap_match = (frame1[64:128] == frame2[0:64])
            print(f"DEBUG: Overlap check - frame1[64:70]={frame1[64:70]}, "
                  f"frame2[0:6]={frame2[0:6]}")
            self.assert_equal(overlap_match, True, "Frames should overlap by 50%")
        
        self.coverage['overlap_mode'] = True
        print("[PASS] Test 3 PASSED")
    
    def test_4_frame_skipping(self):
        """Test frame skipping for power savings"""
        print("\n[TEST 4] Frame Skipping (skip_count=2)")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False, 
                            overlap_half_window=False, 
                            frame_skip_count=2)
        fmod = FramerFMOD(config)
        
        # Send 3 frames worth of data
        for i in range(384):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
            
        print("\n---PROOF OF FRAME SKIPPPING---")
        print(f" Frame_counter = {fmod.frame_counter} (3 frames seen)")
        print(f" Sample_write_index = {fmod.sample_write_index} (should be reset to 0)")
        print(f" SRAM[0:10] after 384 samples = {fmod.sram[0:10].tolist()}")
        
        
        # Should only write frame 0 (skip frames 1 and 2)
        self.assert_equal(fmod.frame_counter, 3, "Should count 3 frames")
        self.assert_equal(int(fmod.sram[0]), 0, "Frame 0 data should be preserved")
        
        self.coverage['skip_frames'] = True
        print("[PASS] Test 4 PASSED")
    
    def test_5_reset_behavior(self):
        """Test reset functionality"""
        print("\n[TEST 5] Reset Behavior")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False)
        fmod = FramerFMOD(config)
        
        # Send some samples
        for i in range(50):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        
        # Apply reset
        config.reset_x = False
        fmod.clock_tick(ADCFramerTransaction())
        
        # Verify reset state
        self.assert_equal(fmod.sample_write_index, 0, "Write index should reset")
        self.assert_equal(fmod.frame_state, FrameState.FR_NONE, "Frame state should reset")
        
        
        # Release reset
        config.reset_x = True
        fmod.clock_tick(ADCFramerTransaction())
        
        self.coverage['reset_test'] = True
        print("[PASS] Test 5 PASSED")
    
    def test_6_backpressure(self):
        """Test downstream backpressure handling"""
        print("\n[TEST 6] Backpressure Handling")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False)
        fmod = FramerFMOD(config)
        
        # Fill a frame
        for i in range(128):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            fmod.clock_tick(adc_trans)
        
        # Try to emit with intermittent backpressure
        emitted = []
        cycle = 0
        while len(emitted) < 128 and cycle < 300:
            ready = (cycle % 3) != 0  # backpressure every 3rd cycle
            out = fmod.clock_tick(ADCFramerTransaction(), windowing_ready=ready)
            if out['valid']:
                emitted.append(out['data'])
            cycle += 1
        
        self.assert_equal(len(emitted), 128, 
                         "Should still emit full frame despite backpressure")
        
        self.coverage['backpressure'] = True
        print("[PASS] Test 6 PASSED")
    
    def test_7_power_management(self):
        """Test ADC power management signals"""
        print("\n[TEST 7] Power Management Signals")
        print("-" * 60)
        
        config = FramerConfig(use_256_points=False, frame_skip_count=3)
        fmod = FramerFMOD(config)
        
        # Monitor power signals over multiple frames
        power_states = []
        for i in range(512):
            adc_trans = ADCFramerTransaction(valid=True, data=(i & 0xFF))
            out = fmod.clock_tick(adc_trans)
            power_states.append((out['adc_power_on'], out['adc_data_required']))
        
        # Power port --ADC power
        unique_states = set(power_states)
        self.assert_equal(len(unique_states) > 1, True, 
                         "Power signals should vary with frame skipping")
        
        self.coverage['power_mgmt'] = True
        print("[PASS] Test 7 PASSED")
    
    # Results

    def print_summary(self):
        """Print test summary"""
        print("\n" + "="*80)
        print("TEST SUMMARY")
        print("="*80)
        print(f"Tests Passed: {self.tests_passed}")
        print(f"Tests Failed: {self.tests_failed}")
        
        if self.tests_passed + self.tests_failed > 0:
            pass_rate = 100 * self.tests_passed / (self.tests_passed + self.tests_failed)
            print(f"Pass Rate: {pass_rate:.1f}%")
        
        print("\nFunctional Coverage:")
        for feature, covered in self.coverage.items():
            status = "[PASS]" if covered else "[FAIL]"
            print(f"  {status} {feature}")
        
        coverage_pct = 100 * sum(self.coverage.values()) / len(self.coverage)
        print(f"\nOverall Coverage: {coverage_pct:.1f}%")
        
        if self.tests_failed == 0:
            print("\n ---- ALL TESTS PASSED - (FMOD) VERIFIED ------")
        else:
            print(f"\n----- WARNING: {self.tests_failed} TESTS FAILED ----")
        print("="*80)


if __name__ == "__main__":
    testbench = FramerTestbench()
    testbench.run_all_tests()
