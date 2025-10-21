`ifndef CORE_STATE_DEFINE_VH
`define CORE_STATE_DEFINE_VH

// Core State Machine States
`define CORE_IDLE       3'd0     // Waiting to start                          
`define CORE_FETCH      3'd1     // Fetch instructions from program memory    
`define CORE_DECODE     3'd2     // Decode instructions into control signals  
`define CORE_REQUEST    3'd3     // Request data from registers or memory     
`define CORE_WAIT       3'd4     // Wait for response from memory if necessary
`define CORE_EXECUTE    3'd5     // Execute ALU and PC calculations           
`define CORE_WRITEBACK  3'd6     // Update registers, NZP, and PC             
`define CORE_DONE       3'd7     // Done executing this block                 

`endif

`ifndef LSU_STATE_DEFINE_VH
`define LSU_STATE_DEFINE_VH

// Core State Machine States
`define LSU_IDLE            2'd0
`define LSU_REQUESTING      2'd1
`define LSU_WAITING         2'd2
`define LSU_DONE            2'd3


`endif

`ifndef OPCODE_STATE_DEFINE_VH
`define OPCODE_STATE_DEFINE_VH

// Core State Machine States
`define OPCODE_ADD              4'd0
`define OPCODE_SUB              4'd1
`define OPCODE_MUL              4'd2
`define OPCODE_DIV              4'd3
`define OPCODE_LOAD             4'd4
`define OPCODE_STORE            4'd5
`define OPCODE_CONST            4'd6
`define OPCODE_RETURN           4'd7


`endif

`ifndef FETCHER_STATE_DEFINE_VH
`define FETCHER_STATE_DEFINE_VH

// Fetcher States
`define FETCHER_IDLE          3'd0
`define FETCHER_FETCHING      3'd1
`define FETCHER_FETCHED       3'd2


`endif

`ifndef ALU_CONTROL_DEFINE_VH
`define ALU_CONTROL_DEFINE_VH

// ALU Control States
`define ALU_ADD          2'd0
`define ALU_SUB          2'd1
`define ALU_MUL          2'd2
`define ALU_DIV          2'd3


`endif