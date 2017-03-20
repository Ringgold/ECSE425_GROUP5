library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- The function of this unit is to decide if the processor need to stall
-- The way to do this is analyze each current running code in each individual stage
-- Then get the values from the analyzed result to decide the stall requirement
entity hazard_detecting_unit is
    GENERIC(
        -- Stage Listing
        IFF   : integer := 1;
        ID   : integer := 2;
        EX   : integer := 3;
        MEM  : integer := 4;
        WB   : integer := 5;

        -- R Type Indicater
        R_TYPE : std_logic_vector(5 downto 0) := "000000";

        -- R Type Function Codes
        --ADD  : std_logic_vector(5 downto 0) := "100000";
        --SUB  : std_logic_vector(5 downto 0) := "100010";
        MULT : std_logic_vector(5 downto 0) := "011000";
        DIV  : std_logic_vector(5 downto 0) := "011010";  
        --AND  : std_logic_vector(5 downto 0) := "100100";
        --OR   : std_logic_vector(5 downto 0) := "100101";
        --NOR  : std_logic_vector(5 downto 0) := "100111";
        --XOR  : std_logic_vector(5 downto 0) := "100110";
        MFHI : std_logic_vector(5 downto 0) := "010000";
        MFLO : std_logic_vector(5 downto 0) := "010010";
        SSLL  : std_logic_vector(5 downto 0) := "000000";
        SSRL  : std_logic_vector(5 downto 0) := "000010";
        SSRA  : std_logic_vector(5 downto 0) := "000011";
        SLT  : std_logic_vector(5 downto 0) := "101010";
        JR   : std_logic_vector(5 downto 0) := "001000"; -- Special

        -- I Type Opcodes
        ADDI   : std_logic_vector(5 downto 0) := "001000";
        SLTI   : std_logic_vector(5 downto 0) := "001010";
        ANDI   : std_logic_vector(5 downto 0) := "001100";
        ORI    : std_logic_vector(5 downto 0) := "001101";
        XORI   : std_logic_vector(5 downto 0) := "001110"; -- Note
        LUI    : std_logic_vector(5 downto 0) := "001111";
        LW     : std_logic_vector(5 downto 0) := "100011";
        SW     : std_logic_vector(5 downto 0) := "101011";

        -- I Type Branching
        BEQ    : std_logic_vector(5 downto 0) := "000100";
        BNE    : std_logic_vector(5 downto 0) := "000101";

        -- J Type Codes
        J      : std_logic_vector(5 downto 0) := "000010";
        JAL    : std_logic_vector(5 downto 0) := "000011" -- Very Special
    );
    PORT(ID_Code  : in  std_logic_vector(31 downto 0);
         EX_Code  : in  std_logic_vector(31 downto 0);
         MEM_Code : in  std_logic_vector(31 downto 0);
         WB_Code  : in  std_logic_vector(31 downto 0);
         stall    : out std_logic := '0'
	);
end hazard_detecting_unit;

architecture behav of hazard_detecting_unit is
    -- Signals to save the decoded values from ID
    SIGNAL ID_opcode : std_logic_vector(5 downto 0);
    SIGNAL ID_rs     : std_logic_vector(4 downto 0);
    SIGNAL ID_rt     : std_logic_vector(4 downto 0);
    SIGNAL ID_funct  : std_logic_vector(5 downto 0);

    -- Signals to save the decoded values from the EX
    SIGNAL EX_opcode : std_logic_vector(5 downto 0);
    SIGNAL EX_rt     : std_logic_vector(4 downto 0);
    SIGNAL EX_rd     : std_logic_vector(4 downto 0);
    SIGNAL EX_funct  : std_logic_vector(5 downto 0);

    -- Signals to save the decoded values from the MEM
    SIGNAL MEM_opcode : std_logic_vector(5 downto 0);
    SIGNAL MEM_rt     : std_logic_vector(4 downto 0);
    SIGNAL MEM_rd     : std_logic_vector(4 downto 0);
    SIGNAL MEM_funct  : std_logic_vector(5 downto 0);

    -- Signals to save the decoded values from the WB
    SIGNAL WB_opcode : std_logic_vector(5 downto 0);
    SIGNAL WB_rt     : std_logic_vector(4 downto 0);
    SIGNAL WB_rd     : std_logic_vector(4 downto 0);
    SIGNAL WB_funct  : std_logic_vector(5 downto 0);

    -- 2 Variable from the ID stage instruction
    SIGNAL RD1 : std_logic_vector(4 downto 0);
    SIGNAL RD2 : std_logic_vector(4 downto 0);
    -- 2 Stage Using Marker from the ID stage instruction
    SIGNAL RD1_Use_Stage : integer;
    SIGNAL RD2_Use_Stage : integer;

    -- Current stage's output value's destination register and its stage we are going to be ready to get it
    -- EX stage 
    SIGNAL EX_Ready_Stage : integer;
    SIGNAL EX_Output : std_logic_vector(4 downto 0);

    -- MEM stage
    SIGNAL MEM_Ready_Stage : integer;
    SIGNAL MEM_Output : std_logic_vector(4 downto 0);

    -- WB stage
    SIGNAL WB_Ready_Stage : integer;
    SIGNAL WB_Output : std_logic_vector(4 downto 0);

    -- EX, MEM, WB stages' needing time
    SIGNAL EX_Output_Need  : integer;
    SIGNAL MEM_Output_Need : integer;
    SIGNAL WB_Output_Need  : integer;

    -- RD1 and RD2 actual pending stall
    SIGNAL RD1_Pending_Stall: integer;
    SIGNAL RD2_Pending_Stall: integer;

begin
    process(ID_Code, EX_Code, MEM_Code, WB_Code)

    begin
        -- Assume no stall are needed as the base case
        stall <= '0';

        -- Analyze the current code in ID stage so that we know what we need to wait for and how long we need to wait

        -- Decode and save values
        ID_opcode <= ID_Code(31 downto 26);
        ID_rs     <= ID_Code(25 downto 21);
        ID_rt     <= ID_Code(20 downto 16);
        ID_funct  <= ID_Code(5 downto 0);

        -- First Analyze the Variables (Registers) we will need
        -- R type
        if (ID_opcode = R_TYPE) then
            -- List out the special cases first (Flushes)
            if (ID_funct = MFHI or ID_funct = MFLO) then
                RD1 <= "00000";
                RD2 <= "00000";
            elsif (ID_funct = JR) then
                RD1 <= ID_rs;
                RD2 <= "00000";
            elsif (ID_funct = SSLL or ID_funct = SSRA or ID_funct = SSRL) then
                RD1 <= "00000";
                RD2 <= ID_rt;
            -- Normal R type just do calculations
            else
                RD1 <= ID_rs;
                RD2 <= ID_rt;
            end if;
        -- I type
        -- Branching and Save need to keep both
        elsif (ID_opcode = BEQ or ID_opcode = BNE or ID_opcode = SW) then
            RD1 <= ID_rs;
            RD2 <= ID_rt;
        -- J Type and LUI
        elsif (ID_opcode = J or ID_opcode = JAL or ID_opcode = LUI) then
            RD1 <= "00000";
            RD2 <= "00000";
        -- Rest of the I types
        else
            RD1 <= ID_rs;
            RD2 <= "00000";
        end if;

        -- Then Analyze the at which stage these variables we will be used
        -- R type
        if (ID_opcode = R_TYPE) then
            -- JR is the special case
            if (ID_funct = JR) then
                RD1_Use_Stage <= ID;
                RD2_Use_Stage <= 0;
            else -- Rest are calculation
                RD1_Use_Stage <= EX;
                RD2_Use_Stage <= EX;
            end if;
        -- I type
        -- Branching Case 
        elsif (ID_opcode = BEQ or ID_opcode = BNE) then
            RD1_Use_Stage <= ID;
            RD2_Use_Stage <= ID;
        elsif (ID_opcode = SW) then
            RD1_Use_Stage <= EX;  -- Address Calculation
            RD2_Use_Stage <= MEM; -- Actual Data
        else -- Rest are Calculations
            RD1_Use_Stage <= EX;
            RD2_Use_Stage <= EX;
        end if;
        -- At this momment we acquired info about the Registers we are going to use and corresponding stage we are going to use them
        -- which are RD1, RD2, RD1_Use_Stage, RD2_Use_Stage

        -- Get RD1 and RD2's pending stall period
        RD1_Pending_Stall <= RD1_Use_Stage - ID;
        RD2_Pending_Stall <= RD2_Use_Stage - ID;

        -- Next, Need to Acquire the info about the outputs and its ready stage for the following 3 stages

        -- First do the decode
        -- EX
        EX_opcode    <= EX_Code(31 downto 26);
        EX_rt        <= EX_Code(20 downto 16);
        EX_rd        <= EX_Code(15 downto 11);
        EX_funct     <= EX_Code(5 downto 0);
        -- MEM
        MEM_opcode    <= MEM_Code(31 downto 26);
        MEM_rt        <= MEM_Code(20 downto 16);
        MEM_rd        <= MEM_Code(15 downto 11);
        MEM_funct     <= MEM_Code(5 downto 0);
        -- WB
        WB_opcode    <= WB_Code(31 downto 26);
        WB_rt        <= WB_Code(20 downto 16);
        WB_rd        <= WB_Code(15 downto 11);
        WB_funct     <= WB_Code(5 downto 0);

        -- EX MEM, and WB stage analyse
        -- Linkage is the only special case
        if (EX_opcode = JAL) then
            EX_Ready_Stage <= EX;
        elsif (EX_opcode = SW) then
            EX_Ready_Stage <= MEM;
        else
            EX_Ready_Stage <= WB;
        end if;

        if (MEM_opcode = JAL) then
            MEM_Ready_Stage <= EX;
        elsif (MEM_opcode = SW) then
            MEM_Ready_Stage <= MEM;
        else
            MEM_Ready_Stage <= WB;
        end if;

        if (WB_opcode = JAL) then
            WB_Ready_Stage <= EX;
        elsif (WB_opcode = SW) then
            WB_Ready_Stage <= MEM;
        else
            WB_Ready_Stage <= WB;
        end if;

        -- EX MEM, and WB output analyse

        -- EX stage
        if (EX_opcode = R_TYPE) then
            -- all saved at LO
            if (EX_funct = MULT or EX_funct = DIV or EX_funct = JR) then
                EX_Output <= "00000";
            else -- others are normal Calculations
                EX_Output <= EX_rd;
            end if;
        -- I type
        -- $31 Linkage
        elsif (EX_opcode = JAL) then 
            EX_Output <= "11111";
        -- Don't Need it for branch, jump, or save
        elsif (EX_opcode = J or EX_opcode = BEQ or EX_opcode = BNE or EX_opcode = SW) then
            EX_Output <= "00000";
        else
            EX_Output <= EX_rt;
        end if;

        -- MEM stage
        if (MEM_opcode = R_TYPE) then
            -- all saved at LO
            if (MEM_funct = MULT or MEM_funct = DIV or MEM_funct = JR) then
                MEM_Output <= "00000";
            else -- others are normal Calculations
                MEM_Output <= MEM_rd;
            end if;
        -- I type
        -- $31 Linkage
        elsif (MEM_opcode = JAL) then 
            MEM_Output <= "11111";
        -- Don't Need it for branch, jump, or save
        elsif (MEM_opcode = J or MEM_opcode = BEQ or MEM_opcode = BNE or MEM_opcode = SW) then
            MEM_Output <= "00000";
        else
            MEM_Output <= MEM_rt;
        end if;

        -- WB stage
        if (WB_opcode = R_TYPE) then
            -- all saved at LO
            if (WB_funct = MULT or WB_funct = DIV or WB_funct = JR) then
                WB_Output <= "00000";
            else -- others are normal Calculations
                WB_Output <= WB_rd;
            end if;
        -- I type
        -- $31 Linkage
        elsif (WB_opcode = JAL) then 
            WB_Output <= "11111";
        -- Don't Need it for branch, jump, or save
        elsif (WB_opcode = J or WB_opcode = BEQ or WB_opcode = BNE or WB_opcode = SW) then
            WB_Output <= "00000";
        else
            WB_Output <= WB_rt;
        end if;

        -- EX, MEM, WB output value and stage info analyzation down
        -- Acquired: 
        -- EX_Output, MEM_Output, WB_Output
        -- EX_Ready_Stage, MEM_Ready_Stage, WB_Ready_Stage

        -- Now Get the time period of each output's acquiring time interval
        EX_Output_Need  <= EX_Ready_Stage  - EX;
        MEM_Output_Need <= MEM_Ready_Stage - MEM;
        WB_Output_Need  <= WB_Ready_Stage  - WB;

        -- Now Perform the comparing between each output stage need (for independency) then decide if stall is needed
        -- EX stage
        if (EX_Output /= "00000") then
            if (EX_Output = RD1 and EX_Output_Need > RD1_Pending_Stall) then
                stall <= '0';
            end if;
            if (EX_Output = RD2 and EX_Output_Need > RD2_Pending_Stall) then
                stall <= '0';
            end if;
        end if;

        -- MEM stage
        if (MEM_Output /= "00000") then
            if (MEM_Output = RD1 and MEM_Output_Need > RD1_Pending_Stall) then
                stall <= '0';
            end if;
            if (MEM_Output = RD2 and MEM_Output_Need > RD2_Pending_Stall) then
                stall <= '0';
            end if;
        end if;

        -- WB Stage
        if (WB_Output /= "00000") then
            if (WB_Output = RD1 and WB_Output_Need > RD1_Pending_Stall) then
                stall <= '0';
            end if;
            if (WB_Output = RD2 and WB_Output_Need > RD2_Pending_Stall) then
                stall <= '0';
            end if;
        end if;
    end process;
end architecture behav;
