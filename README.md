
🚀 Raven_SoC Physical Design (PD) Implementation – 14nm  
📌Objective:  
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


VLSI Physical Design Flow

🧠 1. Logic Synthesis
Purpose:
Translate RTL (Verilog/VHDL) into a technology-mapped gate-level netlist using tools like Design Compiler.  
Inputs:  
RTL (HDL) code  
Technology libraries (.lib)  
Design constraints (.sdc)  
Multivoltage intent (.upf)  
Outputs:  
Gate-level netlist (.v)  
Synthesis reports (timing, area, power)  
Initial constraints (.sdc)  
Objective:  
Generate an optimized netlist that meets functionality, timing, and design constraints, acting as the handoff to physical design.

🛠️ 2. Physical Synthesis (Optional but Powerful)
Purpose:  
Refines the netlist further using placement-aware synthesis to close timing early and improve correlation between synthesis and layout stages.  
Inputs:  
Synthesized gate-level netlist  
Physical floorplan (placement-aware)  
Technology libraries  
Timing constraints (.sdc)  
Outputs:  
Improved netlist (with buffering, restructuring)  
Updated constraints  
Physical synthesis reports  
Objective:
Improve timing closure, congestion, and routability before standard cell placement by using early layout feedback.

📥 3. Import Design (Netlist-In)
Purpose:
Set up the design environment and load all files into the PnR tool (e.g., IC Compiler II).  
Inputs:  
Gate-level netlist (.v)  
Constraints (.sdc)  
Power intent (.upf)  
Tech files (.lef, .lib, .tlu+, .tf)  
DEF (if macros placed)  
Outputs:  
Loaded and initialized design in tool database  
Objective:   
Ensure all required design and tech files are correctly imported for physical implementation.

🧱 4. Floorplanning (Chip Planning)  
Purpose:
Create a chip-level physical map for blocks/macros, routing channels, and power grid.  
Inputs:  
Netlist  
Technology files  
Macro LEFs and DEF (if pre-placed)  
IO constraints  
Outputs:  
Floorplan (core area, die size)  
Macro and IO pin locations  
Power grid structure  
Blockage regions  
Objective:  
Optimize for area, timing, and routing resources by intelligent macro placement and IO planning.  

🧩 5. Placement
Purpose:  
Place standard cells in the core area based on floorplan and optimization goals.  
Inputs:  
Netlist  
Floorplan  
Tech rules 
Timing constraints  
Outputs:  
Placed netlist  
Congestion/timing/area reports  
DEF with cell locations  
Objective:  
Optimize cell positions for timing, power, and congestion; ensure the design is routable.

⏰ 6. Clock Tree Synthesis (CTS)
Purpose:  
Distribute the clock signal evenly to sequential elements to minimize skew and insertion delay.  
Inputs: 
Placed design  
Clock definitions and constraints  
Technology info  
Outputs: 
Clock tree buffers/inverters inserted  
Updated netlist with clock routing  
Skew and latency reports  
Objective:  
Meet clock-related constraints like max skew, insertion delay, and transition limits.

🔗 7. Routing
Purpose:
Create metal interconnections for all signal nets, clock nets, and power routing.  
Inputs:  
Clock tree inserted design  
Timing & design constraints  
Tech rules for metal layers, vias  
Outputs:  
Routed design (DEF/GDSII)  
DRC/LVS-clean layout  
Parasitic data (SPEF/RC)  
Routing reports (length, congestion)  
Objectiv
Meet timing, signal integrity, power, and DRC goals while minimizing wirelength and congestion.  






