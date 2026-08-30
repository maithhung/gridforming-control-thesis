# Bachelor Thesis – Thanh Hung Mai

**Lab-scale comparison of grid-forming control techniques under various operating conditions**  
Technische Universität Berlin · Department of Power Electronics · 2025

## Abstract

Grid-forming inverters (GFMIs) can support voltage and frequency in power systems with a high share of renewable generation, but their stability in realistic grid conditions remains an open research problem. This thesis investigates how inner control structures and primary control strategies interact in a laboratory-scale GFMI. Cascaded voltage–current control, virtual impedance, frequency droop control, and virtual synchronous generator (VSG) control are modelled, implemented, and compared. A two-level three-phase converter is connected to a programmable grid emulator through configurable Thevenin-equivalent impedances representing low-, medium-, and high-voltage network characteristics. The experiments assess active/reactive power response, grid-strength variation, phase jumps, and frequency changes with significant rate of change of frequency (RoCoF). Measurement results are interpreted using phase-plane analysis to relate observed transient behaviour to the outer-loop dynamics and converter current limits.

## Key Contributions

- Compared GFMI control combinations across inner cascaded control, virtual impedance, droop control, and VSG control.
- Developed a reproducible lab-scale benchmark using a two-level three-phase converter, grid emulator, and configurable Thevenin-equivalent grid impedance.
- Translated low-, medium-, and high-voltage network characteristics and multiple short-circuit-ratio (SCR) conditions to the laboratory setup.
- Evaluated controller behaviour under power steps, R/X and SCR variation, severe phase jumps, and frequency ramps with RoCoF of 1 Hz/s.
- Used phase-plane models to validate measured droop behaviour and investigate the stability limits of VSG control.

## Methodology

The study combines literature review, analytical modelling, MATLAB-based scheme development, real-time control implementation, and laboratory measurement. AC quantities are represented in the dq0 frame and grid parameters are converted using the per-unit system. The GFMI is controlled through either an inner cascaded voltage–current loop or a direct voltage-source structure, with virtual impedance used as a stabilizing and current-limiting mechanism. Primary control is provided by frequency–power/voltage–reactive-power droop or by a VSG swing-equation model. The public source subset contains the MATLAB scheme and parameter files; hardware-interface and deployment code for FPGA are omitted. The original implementation was deployed with Vitis Model Composer on a dSPACE MicroLabBox and tested through a Cinergia grid emulator.

## Results

The cascaded loop reduced the measured power-step settling time from roughly 2 s to 1 s, while producing less reactive-power deviation but rougher current and frequency waveforms. Virtual impedance improved damping, particularly for VSG control, at the cost of slower response and larger reactive-power offset. VSG control supplied a smoother frequency response and kept active-power overshoot below 10% in the tested step, whereas droop responded with almost no virtual inertia. Open-loop droop survived a −20° phase jump and a 50–52.5 Hz ramp at 1 Hz/s, but failed at −40° because of current limitation. The results demonstrate that inner-loop choices, grid impedance, and protection limits must be considered together.

## Repository Structure

Only selected, publishable source material is included online. The repository is intentionally kept simple and focuses on MATLAB/Simulink files for the investigated control schemes. Full control code and implementation details can be requested personally.

```text
.
└── ba-thesis-thanh-hung-mai-droop-control/
    └── src/                        # Public MATLAB/Simulink scheme files
        ├── single_loop_droop.slx   # Direct voltage-source droop scheme
        ├── cascaded_droop_vi.slx   # Cascaded droop with virtual impedance
        ├── sing_loop_vsg.slx       # Direct VSG scheme
        ├── LCL.m                   # LCL filter calculations
        └── parameters.m            # Main model parameters
```

The public source subset is intended to contain key files such as `single_loop_droop.slx`, `cascaded_droop_vi.slx`, `sing_loop_vsg.slx`, `LCL.m`, and the associated parameter files. Raw measurement data, generated Simulink/build artifacts, proprietary or hardware-specific interface files, and the complete deployment source are intentionally not part of the public release.

## Hardware Interface and Usage

The laboratory setup consists of a two-level, three-phase converter connected to a Cinergia programmable grid emulator through an external three-phase line impedance. The line impedance represents the Thevenin equivalent of the selected grid and is configured to reproduce different R/X ratios, voltage-network characteristics, and short-circuit ratios (SCRs). The converter is rated at approximately 2 kVA and is operated from a 309 V DC link at a 3.2 kHz switching frequency.

During the original experiments, the controller was implemented in Simulink and deployed through Vitis Model Composer to a dSPACE MicroLabBox. The MicroLabBox generated the converter control/PWM signals and acquired measurement signals from both the inverter side and the grid side. Current-limiting and over-current protection were enabled to protect the laboratory hardware, although protection behaviour itself was outside the main controller comparison.

For a conceptual usage workflow:

1. Select a published droop, cascaded droop with virtual impedance, or VSG scheme and load its parameter file.
2. Set the operating point and configure the equivalent grid impedance through the desired R/X ratio and SCR.
3. Apply a controlled test disturbance, such as an active/reactive power step, phase-angle jump, or frequency ramp.
4. Record voltage, current, active/reactive power, and frequency responses for comparison and phase-plane analysis.

The public repository documents the schemes and parameters only. The hardware driver, signal-mapping, real-time deployment, and protection-interface code are intentionally omitted; running the experiments therefore requires the original laboratory hardware and toolchain.

## References

- M. C. Chandorkar, D. M. Divan, and R. Adapa, “Control of Parallel Connected Inverters in Standalone AC Supply Systems,” *IEEE Transactions on Industry Applications*, 1993. [doi:10.1109/28.195899](https://doi.org/10.1109/28.195899)
- W. Du *et al.*, “A Comparative Study of Two Widely Used Grid-Forming Droop Controls on Microgrid Small-Signal Stability,” *IEEE Journal of Emerging and Selected Topics in Power Electronics*, 2020. [doi:10.1109/JESTPE.2019.2942491](https://doi.org/10.1109/JESTPE.2019.2942491)
- S. D’Arco and J. A. Suul, “Equivalence of Virtual Synchronous Machines and Frequency-Droops for Converter-Based MicroGrids,” *IEEE Transactions on Smart Grid*, 2014. [doi:10.1109/TSG.2013.2288000](https://doi.org/10.1109/TSG.2013.2288000)
- M. Eggers, P. Teske, and S. Dieckerhoff, “Virtual-Impedance-Based Current-Limitation of Grid-Forming Converters for Balanced and Unbalanced Voltage Sags,” *IEEE PEDG*, 2022. [doi:10.1109/PEDG54999.2022.9923159](https://doi.org/10.1109/PEDG54999.2022.9923159)
- ENTSO-E, *Grid Forming Capability of Power Park Modules*, 2024.
- P. Kundur, *Power System Stability and Control*. McGraw-Hill, 1994.
