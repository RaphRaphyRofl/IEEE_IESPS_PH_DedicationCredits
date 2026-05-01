`default_nettype none

module tt_um_vga_example (
    input  wire [7:0] ui_in,    // ui_in[1:0] for colors
    output wire [7:0] uo_out,   // VGA pins
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    // ==========================================
    // 1. VGA TIMING & SYNC
    // ==========================================
    reg [9:0] h_cnt, v_cnt;
    always @(posedge clk) begin
        if (~rst_n) begin h_cnt <= 0; v_cnt <= 0; end
        else begin
            if (h_cnt == 799) begin
                h_cnt <= 0;
                v_cnt <= (v_cnt == 524) ? 0 : v_cnt + 1;
            end else h_cnt <= h_cnt + 1;
        end
    end

    wire hsync = ~(h_cnt >= 656 && h_cnt < 752);
    wire vsync = ~(v_cnt >= 490 && v_cnt < 492);
    wire display_on = (h_cnt < 640) && (v_cnt < 480);

    // ==========================================
    // 2. GRID SYSTEM (40x30 Tiles)
    // ==========================================
    wire [5:0] row = v_cnt[9:4]; 
    wire [5:0] col = h_cnt[9:4]; 
    wire [2:0] px  = h_cnt[3:1]; 
    wire [2:0] py  = v_cnt[3:1];

    // ==========================================
    // 3. TILEMAP (The "Long Code" Style)
    // ==========================================
    reg [7:0] char;
    always @(*) begin
        char = 8'h20; // Default Space
        case (row)
            // Header
            6'd01: case(col) 12:char="I"; 13:char="E"; 14:char="E"; 15:char="E"; 17:char="I"; 18:char="E"; 19:char="S"; 20:char="-"; 21:char="I"; 22:char="P"; 23:char="S"; 25:char="P"; 26:char="H"; endcase
            6'd02: case(col) 12:char="P"; 13:char="R"; 14:char="O"; 15:char="J"; 16:char="E"; 17:char="C"; 18:char="T"; 20:char="C"; 21:char="R"; 22:char="E"; 23:char="D"; 24:char="I"; 25:char="T"; 26:char="S"; endcase
            
            // Names
            6'd04: case(col) 10:char="C"; 11:char="h"; 12:char="i"; 13:char="c"; 14:char="o"; 16:char="A"; 17:char="n"; 18:char="d"; 19:char="r"; 20:char="e"; 22:char="O"; 23:char="l"; 24:char="a"; 25:char="g"; 26:char="u"; 27:char="e"; 28:char="r"; endcase
            6'd05: case(col) 13:char="R"; 14:char="a"; 15:char="p"; 16:char="h"; 17:char="a"; 18:char="e"; 19:char="l"; 21:char="G"; 22:char="a"; 23:char="r"; 24:char="c"; 25:char="i"; 26:char="a"; endcase
            6'd06: case(col) 10:char="F"; 11:char="r"; 12:char="e"; 13:char="d"; 15:char="D"; 16:char="a"; 17:char="n"; 18:char="i"; 19:char="e"; 20:char="l"; 22:char="I"; 23:char="g"; 24:char="n"; 25:char="a"; 26:char="c"; 27:char="i"; 28:char="o"; endcase
            6'd07: case(col) 10:char="K"; 11:char="y"; 12:char="l"; 13:char="e"; 15:char="P"; 16:char="a"; 17:char="t"; 18:char="r"; 19:char="i"; 20:char="c"; 21:char="k"; 23:char="G"; 24:char="a"; 25:char="l"; 26:char="a"; 27:char="n"; 28:char="g"; endcase
            6'd08: case(col) 12:char="V"; 13:char="i"; 14:char="t"; 15:char="o"; 17:char="L"; 18:char="e"; 19:char="o"; 20:char="n"; 22:char="G"; 23:char="a"; 24:char="m"; 25:char="b"; 26:char="o"; 27:char="a"; endcase
            6'd09: case(col) 9:char="C"; 10:char="h"; 11:char="a"; 12:char="r"; 13:char="l"; 14:char="e"; 15:char="s"; 17:char="V"; 18:char="i"; 19:char="n"; 20:char="c"; 21:char="e"; 22:char="n"; 23:char="t"; 25:char="D"; 26:char="u"; 27:char="l"; 28:char="a"; 29:char="y"; endcase
            6'd10: case(col) 10:char="S"; 11:char="o"; 12:char="f"; 13:char="i"; 14:char="a"; 16:char="N"; 17:char="a"; 18:char="d"; 19:char="i"; 20:char="n"; 21:char="e"; 23:char="T"; 24:char="a"; 25:char="b"; 26:char="a"; 27:char="b"; 28:char="a"; endcase
            6'd11: case(col) 8:char="J"; 9:char="o"; 10:char="a"; 11:char="q"; 12:char="u"; 13:char="i"; 14:char="n"; 16:char="G"; 17:char="a"; 18:char="b"; 19:char="r"; 20:char="i"; 21:char="e"; 22:char="l"; 24:char="R"; 25:char="o"; 26:char="s"; 27:char="a"; 28:char="r"; 29:char="i"; 30:char="o"; endcase
            6'd12: case(col) 9:char="D"; 10:char="r"; 11:char="."; 13:char="A"; 14:char="l"; 15:char="e"; 16:char="x"; 17:char="a"; 18:char="n"; 19:char="d"; 20:char="e"; 21:char="r"; 23:char="C"; 24:char="o"; 26:char="A"; 27:char="b"; 28:char="a"; 29:char="d"; endcase
            
            // Special Thanks
            6'd15: case(col) 11:char="S"; 12:char="P"; 13:char="E"; 14:char="C"; 15:char="I"; 16:char="A"; 17:char="L"; 19:char="T"; 20:char="H"; 21:char="A"; 22:char="N"; 23:char="K"; 24:char="S"; 26:char="T"; 27:char="O"; endcase
            6'd16: case(col) 11:char="I"; 12:char="E"; 13:char="E"; 14:char="E"; 16:char="O"; 17:char="p"; 18:char="e"; 19:char="n"; 21:char="S"; 22:char="i"; 23:char="l"; 24:char="i"; 25:char="c"; 26:char="o"; 27:char="n"; endcase
            6'd17: case(col) 14:char="T"; 15:char="i"; 16:char="n"; 17:char="y"; 18:char="T"; 19:char="a"; 20:char="p"; 21:char="e"; 22:char="o"; 23:char="u"; 24:char="t"; endcase
            
            // Quote 1
            6'd20: case(col) 2:char="D"; 3:char="o"; 5:char="n"; 6:char="o"; 7:char="t"; 9:char="g"; 10:char="o"; 12:char="g"; 13:char="e"; 14:char="n"; 15:char="t"; 16:char="l"; 17:char="e"; 19:char="i"; 20:char="n"; 21:char="t"; 22:char="o"; 24:char="t"; 25:char="h"; 26:char="a"; 27:char="t"; 29:char="g"; 30:char="o"; 31:char="o"; 32:char="d"; 33:char="n"; 34:char="i"; 35:char="g"; 36:char="h"; 37:char="t"; endcase
            6'd21: case(col) 13:char="-"; 15:char="D"; 16:char="y"; 17:char="l"; 18:char="a"; 19:char="n"; 21:char="T"; 22:char="h"; 23:char="o"; 24:char="m"; 25:char="a"; 26:char="s"; endcase

            // Quote 2
            6'd23: case(col) 9:char="L"; 10:char="i"; 11:char="f"; 12:char="e"; 14:char="i"; 15:char="s"; 17:char="r"; 18:char="e"; 19:char="a"; 20:char="s"; 21:char="o"; 22:char="n"; 24:char="-"; 26:char="R"; 27:char="o"; 28:char="c"; 29:char="k"; 30:char="y"; 31:char=","; endcase
            6'd24: case(col) 11:char="P"; 12:char="r"; 13:char="o"; 14:char="j"; 15:char="e"; 16:char="c"; 17:char="t"; 19:char="H"; 20:char="a"; 21:char="i"; 22:char="l"; 24:char="M"; 25:char="a"; 26:char="r"; 27:char="y"; endcase
            
            // Humanity Message
            6'd27: case(col) 4:char="A"; 5:char="d"; 6:char="v"; 7:char="a"; 8:char="n"; 9:char="c"; 10:char="i"; 11:char="n"; 12:char="g"; 14:char="t"; 15:char="e"; 16:char="c"; 17:char="h"; 18:char="n"; 19:char="o"; 20:char="l"; 21:char="o"; 22:char="g"; 23:char="y"; 25:char="f"; 26:char="o"; 27:char="r"; 29:char="h"; 30:char="u"; 31:char="m"; 32:char="a"; 33:char="n"; 34:char="i"; 35:char="t"; 36:char="y"; endcase
        endcase
    end

    // ==========================================
    // 4. FONT ROM
    // ==========================================
    reg [7:0] font_row_data;
    always @(*) begin
        case(char)
            "A": case(py) 0:font_row_data=8'h18; 1:font_row_data=8'h3C; 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h7E; 5:font_row_data=8'h66; 6:font_row_data=8'h66; default:font_row_data=0; endcase
            "C": case(py) 0:font_row_data=8'h3C; 1:font_row_data=8'h66; 2:font_row_data=8'h60; 3:font_row_data=8'h60; 4:font_row_data=8'h60; 5:font_row_data=8'h66; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "D": case(py) 0:font_row_data=8'hF8; 1:font_row_data=8'h6C; 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h6C; 6:font_row_data=8'hF8; default:font_row_data=0; endcase
            "E": case(py) 0:font_row_data=8'hFE; 1:font_row_data=8'h62; 2:font_row_data=8'h68; 3:font_row_data=8'h78; 4:font_row_data=8'h68; 5:font_row_data=8'h62; 6:font_row_data=8'hFE; default:font_row_data=0; endcase
            "F": case(py) 0:font_row_data=8'hFE; 1:font_row_data=8'h62; 2:font_row_data=8'h68; 3:font_row_data=8'h78; 4:font_row_data=8'h68; 5:font_row_data=8'h60; 6:font_row_data=8'hF0; default:font_row_data=0; endcase
            "G": case(py) 0:font_row_data=8'h3C; 1:font_row_data=8'h66; 2:font_row_data=8'h60; 3:font_row_data=8'h6E; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "H": case(py) 0:font_row_data=8'h66; 1:font_row_data=8'h66; 2:font_row_data=8'h66; 3:font_row_data=8'h7E; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h66; default:font_row_data=0; endcase
            "I": case(py) 0:font_row_data=8'h7E; 1:font_row_data=8'h18; 2:font_row_data=8'h18; 3:font_row_data=8'h18; 4:font_row_data=8'h18; 5:font_row_data=8'h18; 6:font_row_data=8'h7E; default:font_row_data=0; endcase
            "J": case(py) 0:font_row_data=8'h1E; 1:font_row_data=8'h0C; 2:font_row_data=8'h0C; 3:font_row_data=8'h0C; 4:font_row_data=8'h0C; 5:font_row_data=8'h6C; 6:font_row_data=8'h38; default:font_row_data=0; endcase
            "K": case(py) 0:font_row_data=8'h66; 1:font_row_data=8'h6C; 2:font_row_data=8'h78; 3:font_row_data=8'h70; 4:font_row_data=8'h78; 5:font_row_data=8'h6C; 6:font_row_data=8'h66; default:font_row_data=0; endcase
            "L": case(py) 0:font_row_data=8'h60; 1:font_row_data=8'h60; 2:font_row_data=8'h60; 3:font_row_data=8'h60; 4:font_row_data=8'h60; 5:font_row_data=8'h60; 6:font_row_data=8'hFE; default:font_row_data=0; endcase
            "M": case(py) 0:font_row_data=8'hC6; 1:font_row_data=8'hEE; 2:font_row_data=8'hFE; 3:font_row_data=8'hF6; 4:font_row_data=8'hC6; 5:font_row_data=8'hC6; 6:font_row_data=8'hC6; default:font_row_data=0; endcase
            "N": case(py) 0:font_row_data=8'hC6; 1:font_row_data=8'hE6; 2:font_row_data=8'hF6; 3:font_row_data=8'hDE; 4:font_row_data=8'hCE; 5:font_row_data=8'hC6; 6:font_row_data=8'hC6; default:font_row_data=0; endcase
            "O": case(py) 0:font_row_data=8'h3C; 1:font_row_data=8'h66; 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "P": case(py) 0:font_row_data=8'hFC; 1:font_row_data=8'h66; 2:font_row_data=8'h66; 3:font_row_data=8'h7C; 4:font_row_data=8'h60; 5:font_row_data=8'h60; 6:font_row_data=8'hF0; default:font_row_data=0; endcase
            "R": case(py) 0:font_row_data=8'hFC; 1:font_row_data=8'h66; 2:font_row_data=8'h66; 3:font_row_data=8'h7C; 4:font_row_data=8'h6C; 5:font_row_data=8'h66; 6:font_row_data=8'hE6; default:font_row_data=0; endcase
            "S": case(py) 0:font_row_data=8'h3E; 1:font_row_data=8'h60; 2:font_row_data=8'h60; 3:font_row_data=8'h3C; 4:font_row_data=8'h06; 5:font_row_data=8'h06; 6:font_row_data=8'h7C; default:font_row_data=0; endcase
            "T": case(py) 0:font_row_data=8'h7E; 1:font_row_data=8'h18; 2:font_row_data=8'h18; 3:font_row_data=8'h18; 4:font_row_data=8'h18; 5:font_row_data=8'h18; 6:font_row_data=8'h18; default:font_row_data=0; endcase
            "V": case(py) 0:font_row_data=8'h66; 1:font_row_data=8'h66; 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h3C; 6:font_row_data=8'h18; default:font_row_data=0; endcase
            
            "a": case(py) 2:font_row_data=8'h3C; 3:font_row_data=8'h06; 4:font_row_data=8'h3E; 5:font_row_data=8'h66; 6:font_row_data=8'h3E; default:font_row_data=0; endcase
            "b": case(py) 0:font_row_data=8'h60; 1:font_row_data=8'h60; 2:font_row_data=8'h7C; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h7C; default:font_row_data=0; endcase
            "c": case(py) 2:font_row_data=8'h3C; 3:font_row_data=8'h66; 4:font_row_data=8'h60; 5:font_row_data=8'h66; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "d": case(py) 0:font_row_data=8'h06; 1:font_row_data=8'h06; 2:font_row_data=8'h3E; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h3E; default:font_row_data=0; endcase
            "e": case(py) 2:font_row_data=8'h3C; 3:font_row_data=8'h66; 4:font_row_data=8'h7E; 5:font_row_data=8'h60; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "f": case(py) 0:font_row_data=8'h1C; 1:font_row_data=8'h30; 2:font_row_data=8'hFC; 3:font_row_data=8'h30; 4:font_row_data=8'h30; 5:font_row_data=8'h30; 6:font_row_data=8'h30; default:font_row_data=0; endcase
            "g": case(py) 2:font_row_data=8'h3E; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h3E; 6:font_row_data=8'h06; 7:font_row_data=8'h3C; default:font_row_data=0; endcase
            "h": case(py) 0:font_row_data=8'h60; 1:font_row_data=8'h60; 2:font_row_data=8'h7C; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'hE6; default:font_row_data=0; endcase
            "i": case(py) 0:font_row_data=8'h18; 2:font_row_data=8'h38; 3:font_row_data=8'h18; 4:font_row_data=8'h18; 5:font_row_data=8'h18; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "j": case(py) 0:font_row_data=8'h0C; 2:font_row_data=8'h1C; 3:font_row_data=8'h0C; 4:font_row_data=8'h0C; 5:font_row_data=8'h0C; 6:font_row_data=8'h0C; 7:font_row_data=8'h38; default:font_row_data=0; endcase
            "k": case(py) 0:font_row_data=8'h60; 1:font_row_data=8'h60; 2:font_row_data=8'h66; 3:font_row_data=8'h6C; 4:font_row_data=8'h78; 5:font_row_data=8'h6C; 6:font_row_data=8'h66; default:font_row_data=0; endcase
            "l": case(py) 0:font_row_data=8'h38; 1:font_row_data=8'h18; 2:font_row_data=8'h18; 3:font_row_data=8'h18; 4:font_row_data=8'h18; 5:font_row_data=8'h18; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "m": case(py) 2:font_row_data=8'hEC; 3:font_row_data=8'hFE; 4:font_row_data=8'hF6; 5:font_row_data=8'hD6; 6:font_row_data=8'hC6; default:font_row_data=0; endcase
            "n": case(py) 2:font_row_data=8'h7C; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'hE6; default:font_row_data=0; endcase
            "o": case(py) 2:font_row_data=8'h3C; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h3C; default:font_row_data=0; endcase
            "p": case(py) 2:font_row_data=8'h7C; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h7C; 6:font_row_data=8'h60; 7:font_row_data=8'hF0; default:font_row_data=0; endcase
            "q": case(py) 2:font_row_data=8'h3E; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h3E; 6:font_row_data=8'h06; 7:font_row_data=8'h0F; default:font_row_data=0; endcase
            "r": case(py) 2:font_row_data=8'h5C; 3:font_row_data=8'h66; 4:font_row_data=8'h60; 5:font_row_data=8'h60; 6:font_row_data=8'hF0; default:font_row_data=0; endcase
            "s": case(py) 2:font_row_data=8'h3E; 3:font_row_data=8'h60; 4:font_row_data=8'h3C; 5:font_row_data=8'h06; 6:font_row_data=8'h7C; default:font_row_data=0; endcase
            "t": case(py) 0:font_row_data=8'h30; 1:font_row_data=8'h30; 2:font_row_data=8'hFC; 3:font_row_data=8'h30; 4:font_row_data=8'h30; 5:font_row_data=8'h34; 6:font_row_data=8'h18; default:font_row_data=0; endcase
            "u": case(py) 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h66; 6:font_row_data=8'h3A; default:font_row_data=0; endcase
            "v": case(py) 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h3C; 6:font_row_data=8'h18; default:font_row_data=0; endcase
            "x": case(py) 2:font_row_data=8'h66; 3:font_row_data=8'h3C; 4:font_row_data=8'h18; 5:font_row_data=8'h3C; 6:font_row_data=8'h66; default:font_row_data=0; endcase
            "y": case(py) 2:font_row_data=8'h66; 3:font_row_data=8'h66; 4:font_row_data=8'h66; 5:font_row_data=8'h3E; 6:font_row_data=8'h06; 7:font_row_data=8'h3C; default:font_row_data=0; endcase
            
            "-": case(py) 3:font_row_data=8'h7E; default:font_row_data=0; endcase
            ".": case(py) 5:font_row_data=8'h18; 6:font_row_data=8'h18; default:font_row_data=0; endcase
            ",": case(py) 5:font_row_data=8'h18; 6:font_row_data=8'h18; 7:font_row_data=8'h30; default:font_row_data=0; endcase
            default: font_row_data = 8'h00;
        endcase
    end

    // ==========================================
    // 5. COLOR LOGIC (Using ui_in[1:0])
    // ==========================================
    wire pixel_on = font_row_data[7 - px];
    reg [1:0] r, g, b;

    always @(*) begin
        if (!display_on) begin r = 0; g = 0; b = 0; end
        else if (pixel_on) begin
            case (ui_in[1:0])
                2'b00: begin r=0; g=v_cnt[0]?2:3; b=0; end // Green
                2'b01: begin r=0; g=0; b=v_cnt[0]?2:3; end // Blue
                2'b10: begin r=v_cnt[0]?2:3; g=v_cnt[0]?1:2; b=0; end // Orange
                2'b11: begin r=v_cnt[0]?2:3; g=v_cnt[0]?2:3; b=v_cnt[0]?2:3; end // White
            endcase
        end else begin r = 0; g = 0; b = 0; end
    end

    assign uo_out = {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};

    // Suppress warnings
    wire _unused_ok = &{ena, ui_in[7:2], uio_in};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule