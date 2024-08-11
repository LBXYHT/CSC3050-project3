module ALU(instruction, reg1, reg2, final_result, flag);
    input [31:0] instruction, reg1, reg2;
    output wire [31:0] final_result;
    output wire [2:0] flag;

    reg [31:0] PC, PC4, offset, result, diff, extension, extension1;
    reg [26:0] sign27;
    reg [18:0] imme4;
    reg [15:0] imme, sign;
    reg [13:0] sign14;
    reg [5:0] op, funct;
    reg [4:0] zero, one, rs, rt, sa;
    reg count, test, sign_bit1, sign_bit2, sign_bito, zero_flag, negative_flag, overflow_flag;
    
    always@(*) begin
        test = 0;
        PC = 32'b0;
        PC4 = {28'b0, 4'b0100};
        zero = 5'b0;
        one = {4'b0, 1'b1};
        op = instruction [31:26];
        funct = instruction [5:0];
        rs = instruction[25:21];
        rt = instruction[20:16];
        sa = instruction[10:6];
        imme = instruction[15:0];

        zero_flag = 0;
        negative_flag = 0;
        overflow_flag = 0;
        case(op) 
        6'b0000_00: 
        begin
        //Add
            case(funct)
            6'b1000_00:
            begin
                sign_bit1 = reg1[31];
                sign_bit2 = reg2[31];
                result = $signed(reg1) + $signed(reg2);
                sign_bito = result[31];
                if ((sign_bit1 == 1 && sign_bit2 == 1 && sign_bito == 0) || (sign_bit1 == 0 && sign_bit2 == 0 && sign_bito == 1)) 
                    begin
                        overflow_flag = 1;
                    end

            end
            
        //Addu
            6'b1000_01:
            begin
                result = reg1 + reg2;
            end

        //And
            6'b1001_00:
            begin
                result = reg1 & reg2;
            end

        //Nor
            6'b1001_11:
            begin
                result = ~(reg1 | reg2);
            end 

        //Or
            6'b1001_01:
            begin
                result = reg1 | reg2;
            end

        //Sll
            6'b0000_00:
            begin
                extension1 = {27'b0, sa};
                case(rt)
                5'b0:
                begin
                    result = reg1 << extension1;
                end
                
                5'b0000_1:
                begin   
                    result = reg2 << extension1;
                end
                endcase

            end
        
        //Sllv
            6'b0001_00:
            begin
                case(rs)
                5'b0:
                begin
                    result = reg1 << reg2;
                end

                5'b0000_1:
                begin
                    result = reg2 << reg1;
                end
                endcase

            end

        //Slt
            6'b1010_10:
            begin
                case(rs)
                5'b0:
                begin
                    result = $signed(reg1) - $signed(reg2);
                    if (result[31] == 1) 
                        begin
                        negative_flag = 1;
                        end
                end

                5'b0000_1:
                begin
                    result = $signed(reg2) - $signed(reg1);
                    if (result[31] == 1) 
                        begin
                        negative_flag = 1;
                        end
                end
                endcase

            end

        //Sltu
            6'b1010_11:
            begin
                case(rs)
                5'b0:
                begin
                    result = reg1 - reg2;
                    if (reg1 < reg2) 
                    begin
                    negative_flag = 1;
                    end
                end

                5'b0000_1:
                begin
                    result = reg2 - reg1;
                    if (reg2 < reg1) 
                        begin
                        negative_flag = 1;
                        end
                end
                endcase

            end
        
        //Sra
            6'b0000_11:
            begin
                sign = sa[4];
                sign27 = {27{sign}};
                extension1 = {sign27, sa};
                case(rt)
                5'b0:
                begin
                    result = $signed(reg1) >> $signed(extension1);
                end
                
                5'b0000_1:
                begin   
                    result = $signed(reg2) >> $signed(extension1);
                end
                endcase

            end

        //Srav
            6'b0001_11:
            begin
                case(rt)
                5'b0:
                begin
                    result = $signed(reg1) >> $signed(reg2);
                end

                5'b0000_1:
                begin
                    result = $signed(reg2) >> $signed(reg1); 
                end
                endcase

            end

        //Srl
            6'b0000_10:
            begin
                extension1 = {27'b0, sa};
                case(rt)
                5'b0:
                begin
                    result = reg1 >> extension1;
                end
                
                5'b0000_1:
                begin   
                    result = reg2 >> extension1;
                end
                endcase

            end

        //Srlv
            6'b0001_10:
            begin
                case(rt)
                5'b0:
                begin
                    result = reg1 >> reg2;
                end

                5'b0000_1:
                begin
                    result = reg2 >> reg1;
                end
                endcase

            end

        //sub
            6'b1000_10:
            begin
                sign_bit1 = reg1[31];
                sign_bit2 = reg2[31];
                case(rs)
                5'b0:
                begin
                    result = $signed(reg1) - $signed(reg2);
                    sign_bito = result[31];
                    if ((sign_bit1 == 1 && sign_bit2 == 0 && sign_bito == 0) || (sign_bit1 == 0 && sign_bit2 == 1 && sign_bito == 1)) 
                        begin
                            overflow_flag = 1;
                        end
                end
                
                5'b0000_1:
                begin
                    result = $signed(reg2) - $signed(reg1);
                    sign_bito = result[31];
                    if ((sign_bit2 == 1 && sign_bit1 == 0 && sign_bito == 0) || (sign_bit2 == 0 && sign_bit1 == 1 && sign_bito == 1)) 
                        begin
                            overflow_flag = 1;
                        end
                end
                endcase

            end
            
        //subu
            6'b1000_11:
            begin
                sign_bit1 = reg1[31];
                sign_bit2 = reg2[31];
                case(rs)
                5'b0:
                begin
                    result = reg1 - reg2;
                end

                5'b0000_1:
                begin
                    result = reg2 - reg1;
                end
                endcase

            end

        //xor
            6'b1001_10:
            begin
                result = reg1 ^ reg2;
            end
        
            endcase
            
        end
        

    //Addi
        6'b0010_00:
        begin
            case(rs)
            5'b0:
            begin
                imme = instruction[15:0];
                sign = {16{imme[15]}};
                extension = {sign, imme};
                result = $signed(reg1) + $signed(extension);
                sign_bit1 = reg1[31];
                sign_bit2 = sign;
                sign_bito = result[31];
                if ((sign_bit1 == 1 && sign_bit2 == 1 && sign_bito == 0) || (sign_bit1 == 0 && sign_bit2 == 0 && sign_bito == 1)) 
                    begin
                        overflow_flag = 1;
                    end
            end

            5'b0000_1:
            begin
                imme = instruction[15:0];
                sign = {16{imme[15]}};
                extension = {sign, imme};
                result = $signed(reg2) + $signed(extension);
                sign_bit1 = reg2[31];
                sign_bit2 = sign;
                sign_bito = result[31];
                if ((sign_bit1 == 1 && sign_bit2 == 1 && sign_bito == 0) || (sign_bit1 == 0 && sign_bit2 == 0 && sign_bito == 1)) 
                    begin
                        overflow_flag = 1;
                    end
            end
            endcase

        end
    
    //Addiu
        6'b0010_01:
        begin
            case(rs)
            5'b0:
            begin
                extension = {16'b0, imme};
                result = reg1 + extension;
            end

            5'b0000_1:
            begin
                extension = {16'b0, imme};
                result = reg2 + extension;
            end
            endcase

        end

    //Andi
        6'b0011_00:
        begin
            case(rs)
            5'b0:
            begin
                extension = {16'b0, imme};
                result = reg1 & extension;
            end

            5'b0000_1:
            begin
                extension = {16'b0, imme};
                result = reg2 & extension;
            end
            endcase

        end
        

    //Beq
        6'b0001_00:
        begin
            case(rs)
            5'b0:
            begin
                result = $signed(reg1) - $signed(reg2);
                if (result == 32'b0)
                    begin
                    zero_flag = 1;
                    end
            end

            5'b0000_1:
            begin
                result = $signed(reg2) - $signed(reg1);
                if (result == 32'b0)
                    begin
                    zero_flag = 1;
                    end
            end
            endcase

        end

    //Bne
        6'b0001_01:
        begin
            case(rs)
            5'b0:
            begin
                result = $signed(reg1) - $signed(reg2);
                if (result == 32'b0)
                    begin
                    zero_flag = 1;
                    end
            end

            5'b0000_1:
            begin
                result = $signed(reg2) - $signed(reg1);
                if (result == 32'b0)
                    begin
                    zero_flag = 1;
                    end
            end
            endcase

        end

    //Lw
        6'b1000_11:
        begin
            sign = {16{imme[15]}};
            extension = {sign, imme};
            case(rs)
            5'b0:
            begin
                result = $signed(reg1) + $signed(extension);
            end

            5'b0000_1:
            begin
                result = $signed(reg2) + $signed(extension);
            end
            endcase
            
        end

    //Ori
        6'b0011_01:
        begin
            extension = {16'b0, imme};
            case(rs)
            5'b0:
            begin
                result = reg1 | extension;
            end
            
            5'b0000_1:
            begin
                result = reg2 | extension;
            end
            endcase

        end

    //Slti
        6'b0010_10:
        begin
            sign = {16{imme[15]}};
            extension = {sign, imme};
            case(rs)
            5'b0:
            begin
                result = $signed(reg1) - $signed(extension);
                if (result[31] == 1) 
                    begin
                    negative_flag = 1;
                    end
            end

            5'b0000_1:
            begin
                result = $signed(reg2) - $signed(extension);
                if (result[31] == 1) 
                    begin
                    negative_flag = 1;
                    end
            end
            endcase

        end
    
    //Sltiu
        6'b0010_11:
        begin
            sign = {16{imme[15]}};
            extension = {sign, imme};
            case(rs)
            5'b0:
            begin
                result = reg1 - extension;
                if (reg1 < extension) 
                    begin
                    negative_flag = 1;
                    end
            end

            5'b0000_1:
            begin
                result = reg2 - extension;
                if (reg2 < extension) 
                    begin
                    negative_flag = 1;
                    end
            end
            endcase

        end
    
    //Sw
        6'b1010_11:
        begin
            sign = {16{imme[15]}};
            extension = {sign, imme};
            case(rs)
            5'b0:
            begin
                result = $signed(reg1) + $signed(extension);
            end

            5'b0000_1:
            begin
                result = $signed(reg2) + $signed(extension);
            end
            endcase

        end

    //Xori
        6'b0011_10:
        begin
            extension = {16'b0, imme};
            case(rs)
            5'b0:
            begin
                result = reg1 ^ extension;
            end

            5'b0000_1:
            begin
                result = reg2 ^ extension;
            end
            endcase

        end
        endcase
    
    end

    assign flag = {zero_flag, negative_flag, overflow_flag};
    assign final_result = result;

endmodule