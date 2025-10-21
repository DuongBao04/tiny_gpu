# tiny_gpu
This is verilog implementation to understand how modern GPU works


## 🧠 GPU Module Overview

### 🔹 Dispatcher
The **Dispatcher** is responsible for distributing work blocks across the available cores.  
- On initialization, it **resets all cores** and their submodules.  
- It then **scans through each core**:
  - If a core is idle (after reset), the Dispatcher **assigns a new block** to it and increments the block counter.
  - If a core signals completion (`core_start && core_done`), the Dispatcher **resets that core** to prepare it for the next block.  

---

### 🔹 Memory Controllers

#### Instruction Memory Controller  
#### Data Memory Controller  
Both controllers manage **global memory access** from the cores — specifically from the **Fetcher** (instruction fetch) and **LSU** (load/store operations).  

Each controller operates through **five states**:  
`IDLE → READ_WAITING / WRITE_WAITING → READ_SERVED / WRITE_SERVED`

**General workflow:**
1. In the `IDLE` state, the controller **scans all available channels** (interfaces between the controller and global memory).  
2. If a channel is free, the controller checks whether any consumer (Fetcher/LSU) has a **read/write request**.  
3. When a request is found, it sends the corresponding `mem_read` or `mem_write` signal to global memory.  
4. After receiving `mem_read_ready` or `mem_write_ready` from memory, and the consumer releases its request, the channel **returns to the `IDLE` state**.

---

### 🔹 Core Architecture

Each **Core** operates as an independent compute unit controlled by a **Scheduler** and composed of several main components.

#### 🧩 Scheduler  
The **Scheduler** manages the execution flow through the following states:  
`IDLE → FETCH → DECODE → REQUEST → WAIT → EXECUTE → WRITEBACK`

- In the `IDLE` state, if a **start** signal is received from the Dispatcher, the Scheduler transitions to `FETCH`.

#### 🧩 Fetcher  
- In the `FETCH` stage, the Fetcher sends a **memory read request** (`mem_read_request`) to the **Instruction Memory Controller** using the **current PC**.  
- It waits for the instruction data to return before moving to the next stage.

#### 🧩 Decoder & Control Unit  
- In the `DECODE` stage:
  - The **Decoder** extracts register addresses (`rd`, `rs`, `rt`) and immediate values (if any).
  - The **Control Unit** decodes the **opcode** (`instruction[15:12]`) to determine the instruction type (e.g., `ADD`, `SUB`, `MUL`, `DIV`), generating control signals such as:
    - `RegWrite`
    - `ALUControl`
    - `MemRead`
    - `MemWrite`

#### 🧩 Load-Store Unit (LSU)
- In the `REQUEST` stage, if the instruction involves memory access, the LSU sends a **read/write request** to the **Data Memory Controller**.  
- It then moves into a **WAITING** state until the memory operation is completed.  
- Meanwhile, the register file prepares the source values (`rs`, `rt`) for use.

#### 🧩 ALU (Arithmetic Logic Unit)
- Once all required data is ready, the core transitions to the **EXECUTE** stage.  
- The ALU performs basic arithmetic operations such as `ADD`, `SUB`, `MUL`, and `DIV`.

#### 🧩 Writeback
- In the final **WRITEBACK** stage:
  - If the instruction is a **ProgramReturn**, the core halts execution.  
  - Otherwise, it **updates the Program Counter (PC)** to the next instruction.  
  - If `RegWrite` is asserted, the result is **written back to the destination register (`rd`)**.

---

### ⚙️ Execution Flow Summary
```mermaid
graph LR
    A[IDLE] -->|start| B[FETCH]
    B --> C[DECODE]
    C --> D[REQUEST]
    D --> E[WAIT]
    E --> F[EXECUTE]
    F --> G[WRITEBACK]
    G -->|next PC| B
    G -->|ProgramReturn| H[Done]
