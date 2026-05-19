# Advanced Wireless Networks – ISAC Interference Mitigation (MATLAB)

This repository provides a MATLAB classroom prototype inspired by the paper:

**Interference Mitigation in 4.9 GHz ISAC Networks: A Multi-domain Resource Management Approach**

> Note: This is **not** an official author-released implementation. It is an educational reproduction of the core idea for assignment and experimentation.

## Overview
The script compares two resource management strategies in a simplified 4.9 GHz vehicular ISAC setting:

- **Baseline**: random RB allocation with fixed max transmit power
- **Proposed**: multi-domain control across
  - Frequency domain (greedy RB balancing)
  - Power domain (distance-based power control)
  - Time domain (periodic link muting)

## Repository Contents
- `isac_interference_sim.m`: Main simulation script (self-contained)

## Quick Start (MATLAB)
Run in MATLAB Command Window:

```matlab
isac_interference_sim
```

## Outputs
After each run, results are saved in the **same folder as the script**:

- `results_overview.png` – comparison figure
- `results_metrics.csv` – key metrics table
- `results_metrics.mat` – MATLAB variables (`base`, `prop`, `summaryTable`)

The script also prints absolute output paths in the console for easy verification.

## Metrics
- **Communication success rate (%)**: ratio of links above SINR threshold
- **Mean SINR (dB)**: average communication quality
- **Mean Radar SNR (dB)**: simplified sensing quality indicator

## Suggested Experiment Knobs
Edit these parameters near the top of the script:
- `Nveh` (number of vehicles)
- `Nrb` (number of resource blocks)
- `SINR_th_dB` (success threshold)
- `Nslot` (simulation horizon)

## Limitations
This prototype intentionally simplifies:
- channel effects (e.g., detailed fading/shadowing)
- optimization formulation from the full paper
- statistical confidence analysis (multi-seed Monte Carlo)

It is designed as a practical starting point for coursework and incremental refinement.