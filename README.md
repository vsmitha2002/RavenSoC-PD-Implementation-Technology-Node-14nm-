
🚀 Raven_SoC Physical Design (PD) Implementation – 14nm

📌 Project Overview

Objective:
Design and implementation of Raven SoC with custom hard macro creation and integration, targeting 14nm technology.

🔥 Key Focus Areas

1.Designed and implemented four hard macros for Raven SoC, optimized for area, power, and performance.
2.Integrated the hard macros into the top-level design with optimized floor planning, placement, and routing.
3.Achieved timing closure using Static Timing Analysis (STA) with multi-voltage domain constraints and physical optimizations.


🧪 Specifications
| Parameter                  | Details                           |
| -------------------------- | --------------------------------- |
| **Technology Node**        | 14nm                              |
| **Top-Level Voltage**      | 0.6V                              |
| **Chip Aspect Ratio**      | 1:1 (Square die)                  |
| **Clocking (Top-Level)**   | `PLL_CLK` = 10ns, `EXT_CLK` = 5ns |
| **Clocking (Sub-Modules)** | 5ns, clock name = `clk`           |
| **Input Ports**            | Placed on Side 1 & Side 3         |
| **Output Ports**           | Placed on Side 2 & Side 4         |


🧩 Sub-Modules & Voltages
| Module Name              | Voltage | Type       | Notes                |
| ------------------------ | ------- | ---------- | -------------------- |
| `Spimemio`               | 0.6V    | Hard Macro | Custom macro         |
| `Picorv32_pcpi_mul`      | 0.6V    | Hard Macro | Fast multiplier      |
| `Picorv32_pcpi_fast_mul` | 0.6V    | Soft Block | Optimized multiplier |
| `Picorv32_reg`           | 0.6V    | Soft Block | Register file        |
| `Simpleuart`             | 0.72V   | Hard Macro | UART interface       |
| `Picorv32_pcpi_div`      | 0.72V   | Hard Macro | Division logic       |


⛓️ SDC Constraints Summary
| Constraint Type        | Value                             |
| ---------------------- | --------------------------------- |
| **Clock Period (sub)** | 5ns                               |
| **Clock Period (top)** | `PLL_CLK` = 10ns, `EXT_CLK` = 5ns |
| **Input Delay**        | 0.5ns                             |
| **Output Delay**       | 0.5ns                             |
| **Load Capacitance**   | 0.2ns                             |
| **Max Fanout**         | 200                               |
| **Max Transition**     | 0.5ns                             |
| **Max Capacitance**    | 50pF                              |


