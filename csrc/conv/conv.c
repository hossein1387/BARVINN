#include <stdio.h>

//
// General parameters
//
const int m = 10;                                   // Spacing between dimension blocks in generated tensors


//
// Convolution parameters
//

// Case 1: 3x3 conv, 10x10 feature map, 2 channel blocks in, 2 channel blocks out, 2x2 bits
const int iprec = 2;                                // Input data precision
const int wprec = 2;                                // Weight precision
const int oprec = 2;                                // Output precision
const int W = 10;                                   // Input width
const int H = 10;                                   // Input height
const int C = 2;                                    // Input channel blocks
const int Fw = 3;                                   // Filter kernel width
const int Fh = 3;                                   // Filter kernel height
const int Fc = 2;                                   // Number of filter set blocks (i.e. number of output channel blocks)
const int Sw = 1;                                   // Filter horizontal (width) stride
const int Pl = 0;                                   // Zero-padding in on the left in the width dimension
const int Pr = 0;                                   // Zero-padding in on the right in the width dimension
const int Pt = 0;                                   // Zero-padding in on the top in the height dimension
const int Pb = 0;                                   // Zero-padding in on the bottom in the height dimension


// Case 2: 3x3 conv, 10x10 feature map, 2 channel blocks in, 2 channel blocks out, 1x1 bits 
/*
const int iprec = 1;                                // Input data precision
const int wprec = 1;                                // Weight precision
const int oprec = 1;                                // Output precision
const int W = 10;                                   // Input width
const int H = 10;                                   // Input height
const int C = 2;                                    // Input channel blocks
const int Fw = 3;                                   // Filter kernel width
const int Fh = 3;                                   // Filter kernel height
const int Fc = 2;                                   // Number of filter set blocks (i.e. number of output channel blocks)
const int Sw = 1;                                   // Filter horizontal (width) stride
const int Pw = 0;                                   // Zero-padding in width dimension
const int Ph = 0;                                   // Zero-padding in height dimension
*/

// Case 3: 3x3 conv, 2x2 upper left corner of feature map, 2 channel blocks in, 2 channel blocks out, 2x2 bits
/*
const int iprec = 2;                                // Input data precision
const int wprec = 2;                                // Weight precision
const int oprec = 2;                                // Output precision
const int W = 2;                                    // Input width
const int H = 2;                                    // Input height
const int C = 2;                                    // Input channel blocks
const int Fw = 3;                                   // Filter kernel width
const int Fh = 3;                                   // Filter kernel height
const int Fc = 2;                                   // Number of filter set blocks (i.e. number of output channel blocks)
const int Sw = 1;                                   // Filter horizontal (width) stride
const int Pw = 1;                                   // Zero-padding in width dimension
const int Ph = 1;                                   // Zero-padding in height dimension
*/

// Tensors
int i_t[H][W][C][iprec];                            // Input tensor
int w_t[Fc][Fh][Fw][C][wprec];                      // Filter weight tensor
int *i_tptr = (int*)i_t;                            // Input address pointer
int *w_tptr = (int*)w_t;                            // Weight address pointer

// Computed MVU parameters to program into CSRs
int ilength0;
int ilength1;
int ilength2;
int ilength3;
int ijump0;
int ijump1;
int ijump2;
int ijump3;
int wlength0;
int wlength1;
int wlength2;
int wlength3;
int wjump0;
int wjump1;
int wjump2;
int wjump3;
int countdown;
int bumpzigzag_on;
int loadshacc_on;
int ioffset;
int woffset;


// Internal parameters
int i_j0;
int i_j1;
int i_j2;
int i_j3;
int i_j4;
int i_zzoff;
int w_zzoff;
int cntdwn;
int i_i0;
int i_i1;
int i_i2;
int i_i3;
int w_i0;
int w_i1;
int w_i2;
int w_i3;
int w_j0;
int w_j1;
int w_j2;
int w_j3;
int w_j4;
int outaddr;

char *i_jump0_str = (char*)"";
char *i_jump1_str = (char*)"";
char *i_jump2_str = (char*)"";
char *i_jump3_str = (char*)"";
char *w_jump0_str = (char*)"";
char *w_jump1_str = (char*)"";
char *w_jump2_str = (char*)"";
char *w_jump3_str = (char*)"";


void assignInternalParams()
{
    i_j0 = iprec;                                 // Move to next channel block and/or column
    i_j1 = ijump0;
    i_j2 = ijump1;
    i_j3 = ijump2;
    i_j4 = ijump3;
    i_zzoff = 0;
    w_zzoff = 0;
    cntdwn = countdown;
    i_i0 = ilength0;
    i_i1 = ilength1;
    i_i2 = ilength2;
    i_i3 = ilength3;
    w_i0 = wlength0;
    w_i1 = wlength1;
    w_i2 = wlength2;
    w_i3 = wlength3;
    w_j0 = wprec;                                 // Move to next channel block and/or column
    w_j1 = wjump0;
    w_j2 = wjump1;
    w_j3 = wjump2;
    w_j4 = wjump3;
    outaddr = 0;
    w_tptr += woffset;
    i_tptr += ioffset;
}


int iw, id = 0;

void bumpZigZag(int curjump)
{
    if (curjump >= bumpzigzag_on)
    {
        int sh = (iw == 0) || (id == iprec-1);

        id++;
        iw--;

        if (sh)
        {
            iw += id+1;
            id = 0;

            if (iw >= iprec+wprec-1)
            {
                id = 0;
                iw = 0;
                sh = 0;
            }
            else if (iw >= wprec)
            {
                id = iw - wprec + 1;
                iw -= id;
            }
            else if (id >= iprec)
            {
                iw = id - iprec + 1;
                id -= iw;
            }
        }

        i_zzoff = id;
        w_zzoff = iw;
        printf("==> Bumped zig-zag: id=%2d, iw=%2d\n", id, iw);
    }
}


int getNextInput()
{   
    if (i_i0 == 0 && i_i1 == 0 && i_i2 == 0 && i_i3 == 0)
    {
        i_i0 = ilength0;
        i_i1 = ilength1;
        i_i2 = ilength2;
        i_i3 = ilength3;
        i_tptr += i_j4;
        printf("\n==> i_j4: %s\n", i_jump3_str);
        return 4;
    }
    else if (i_i0 == 0 && i_i1 == 0 && i_i2 == 0)
    {
        i_i0 = ilength0;
        i_i1 = ilength1;
        i_i2 = ilength2;
        i_i3--;
        i_tptr += i_j3;
        printf("\n==> i_j3: %s\n", i_jump2_str);
        return 3;
    }
    else if (i_i0 == 0 && i_i1 == 0)
    {
        i_i0 = ilength0;
        i_i1 = ilength1;
        i_i2--;
        i_tptr += i_j2;
        printf("\n==> i_j2: %s\n", i_jump1_str);
        return 2;
    }
    else if (i_i0 == 0)
    {
        i_i0 = ilength0;
        i_i1--;
        i_tptr += i_j1;
        if (i_j1 != iprec)
            printf("\n==> i_j1: %s\n", i_jump0_str);
        else
            printf("\n");
        
        return 1;
    }
    else
    {
        i_i0--;
        i_tptr += i_j0;       
        return 0;
    }
}

int getNextWeight()
{
    if (w_i0 == 0 && w_i1 == 0 && w_i2 == 0 && w_i3 == 0)
    {
        w_i0 = wlength0;
        w_i1 = wlength1;
        w_i2 = wlength2;
        w_i3 = wlength3;
        w_tptr += w_j4;
        printf("==> w_j4: %s\n", w_jump3_str);
        return 4;
    }
    else if (w_i0 == 0 && w_i1 == 0 && w_i2 == 0)
    {
        w_i0 = wlength0;
        w_i1 = wlength1;
        w_i2 = wlength2;
        w_i3--;
        w_tptr += w_j3;
        printf("==> w_j3: %s\n", w_jump2_str);
        return 3;
    }
    else if (w_i0 == 0 && w_i1 == 0)
    {
        w_i0 = wlength0;
        w_i1 = wlength1;
        w_i2--;
        w_tptr += w_j2;
        printf("==> w_j2: %s\n", w_jump1_str);
        return 2;
    }
    else if (w_i0 == 0)
    {
        w_i0 = wlength0;
        w_i1--;
        w_tptr += w_j1;
        printf("==> w_j1: %s\n", w_jump0_str);
        return 1;
    }
    else
    {
        w_i0--;
        w_tptr += w_j0;
        return 0;
    }

}

int genNextOutput(int curjump)
{
    if ((1 << curjump) >= loadshacc_on)
    {
        outaddr += oprec;
        printf("==> shacc load. Next output addr = %05d\n", outaddr);
    }
}


/*
 Computes parameters for 2-D convolution for one output row 
 on interior of input map (VALID in TF lingo)
*/
void setConv2dlineValid()
{
    // Scheme 1: Compute all output pixels for a single line, but only the first output channel block
    // -note that this would require adding in jumps to the output address to skip over the locations
    //  for the next output channel blocks
    // -subsequent conv2dline operations would need to be executed to fill in the remaining output
    //  channel blocks
    /*
    ilength0 = C*Fw-1;
    ilength1 = Fh-1;
    ilength2 = iprec*wprec-1;
    ilength3 = ((W-Fw+1)/Sw - 1);
    ijump0 = iprec*(C*(W-Fw) + 1);                    i_jump0_str = "Move to next row";
    ijump1 = -iprec*(C*(Fh-1)*W + Fw*C - 1);          i_jump1_str = "Move back to start of window; bump zig-zag";
    ijump2 = -iprec*(C*(Fh-1)*W + (Fw-Sw-1)*C + 1);   i_jump2_str = "Move window to right by horizontal stride";
    ijump3 = 0;                                       i_jump3_str = "";
    wlength0 = C*Fw*Fh-1;                             // Total size of a filter
    wlength1 = 0;
    wlength2 = 0;
    wlength3 = 0;
    wjump0 = -wprec*(C*Fw*Fh-1);                      // Move back to start of filter for next precision combo; Bump zig-zag
    wjump1 = 0;
    wjump2 = 0;
    wjump3 = wjump0;
    countdown = (C * Fw) * (Fh) * (iprec * wprec) * ((W-Fw+1)/Sw);
    */

    // Scheme 2: Compute all of the output pixels for a single line including all output channel blocks
    ilength0 = C*Fw-1;                                                          // Width of filter window X number of input channel blocks
    ilength1 = Fh-1;                                                            // Height of filter
    ilength2 = iprec*wprec*Fc-1;                                                // Number of bit combos X filter sets
    ilength3 = 0;
    ijump0 = iprec*(C*(W-Fw) + 1);                                              i_jump0_str = (char*)"Move to next row";
    ijump1 = -iprec*(C*(Fh-1)*W + Fw*C - 1);                                    i_jump1_str = (char*)"Move back to start of window";
    ijump2 = -iprec*(C*(Fh-1)*W + (Fw-Sw-1)*C + 1);                             i_jump2_str = (char*)"Move window to right by horizontal stride";
    ijump3 = ijump2;                                                            i_jump3_str = (char*)"Move window to right by horizontal stride";
    wlength0 = C*Fw*Fh-1;                                                       // Total size of one filter block
    wlength1 = iprec*wprec-1;                                                   // Number of bit combos
    wlength2 = Fc-1;                                                            // Number of filter blocks
    wlength3 = 0;
    wjump0 = -wprec*(C*Fw*Fh-1);                                                w_jump0_str = (char*)"Move back to start of filter for next precision combo";
    wjump1 = wprec;                                                             w_jump1_str = (char*)"Move to next filter set block";
    wjump2 = -wprec*(C*Fw*Fh*Fc-1);                                             w_jump2_str = (char*)"Move back to start of first filter set block for next window";
    wjump3 = wjump2;                                                            w_jump3_str = (char*)"Move back to start of first filter set block for next window";
    countdown = (C * Fw) * (Fh) * (iprec * wprec) * (Fc) * ((W-Fw+1)/Sw);
    bumpzigzag_on = 1;
    loadshacc_on = 1 << 2;
    woffset = 0;                                                                // Filter pointer offset
    
}

/*
 Computes parameters to do the convolution in the corner/edge of an input feature map
 when there is "virtual" padding (i.e. no actual zeros in memory). Needed where the output 
 feature map is the same size as the input feature map in width and height (i.e. SAME in TF lingo)
 Pl and Pr are mutully exclusive, as are Pt and Pb. Set the one not being used to 0.
*/
void setConv2dlineEdgePadding(int Pl, int Pr, int Pt, int Pb)
{
    // Upper left corner
    if (Pt > 0 && Pl > 0)
    {
        printf("=Upper left corner=\n");
        woffset = wprec*C*(Pt*Fw + Pl);                                             // Start on weight tile within in the first filter block
        ioffset = 0;
        ilength0 = C*(Fw-Pl)-1;                                                     // Width of filter window X number of input channel blocks
        ilength1 = Fh-Pt-1;                                                         // Height of filter
        ilength2 = iprec*wprec*Fc-1;                                                // Number of bit combos X number of filter sets
        ilength3 = 0;                                                               // Not needed. Countdown will terminate.
        ijump0 = iprec*(C*(W-Fw+Pl) + 1);                                           i_jump0_str = (char*)"Move to next row";
        ijump1 = -iprec*(C*(Fh-Pt-1)*W + (Fw-Pl)*C - 1);                            i_jump1_str = (char*)"Move back to start of window";
        ijump2 = ijump1;                                                            i_jump2_str = i_jump1_str;
        ijump3 = ijump1;                                                            i_jump3_str = i_jump1_str;
        wlength0 = C*(Fw-Pl)-1;                                                     // One subset of the columns of the filter
        wlength1 = Fh-Pt-1;                                                         // Subset of the rows of the filter
        wlength2 = iprec*wprec-1;                                                   // Number of bit combos
        wlength3 = Fc-1;                                                            // Number of filter sets, but don't really need since countdown will terminate
        wjump0 = wprec*(C*Pl+1);                                                    w_jump0_str = (char*)"Jump to next row of filter set";
        wjump1 = -wprec*(C*Fw*Fh - 1) + woffset;                                    w_jump1_str = (char*)"Move back to start of filter for next bit combo";
        wjump2 = wprec + woffset;                                                   w_jump2_str = (char*)"Move to next filter set block";
        wjump3 = 0;                                                                 w_jump3_str = (char*)"Not needed!";
        countdown = (C * (Fw-Pl)) * (Fh-Pt) * (iprec * wprec) * (Fc);
        bumpzigzag_on = 2;
        loadshacc_on = 1 << 3;       
    }
    // Upper right corner
    else if (Pt > 0 && Pr > 0)
    {
        printf("=Upper right corner=\n");
        woffset = wprec*C*Pt*Fw;                                                    // Start on correct row of first filter block
        ioffset = iprec*(C*(W-Fw+Pr));                                              // Start on right edge of input feature map
        ilength0 = C*(Fw-Pr)-1;                                                     // Width of filter window X number of input channel blocks
        ilength1 = Fh-Pt-1;                                                         // Height of filter
        ilength2 = iprec*wprec*Fc-1;                                                // Number of bit combos X number of filter sets
        ilength3 = 0;                                                               // Not needed. Countdown will terminate.
        ijump0 = iprec*(C*(W-Fw+Pr) + 1);                                           i_jump0_str = (char*)"Move to next row";
        ijump1 = -iprec*(C*(Fh-Pt-1)*W + (Fw-Pr)*C - 1);                            i_jump1_str = (char*)"Move back to start of window";
        ijump2 = ijump1;                                                            i_jump2_str = i_jump1_str;
        ijump3 = ijump1;                                                            i_jump3_str = i_jump1_str;
        wlength0 = C*(Fw-Pr)-1;                                                     // One subset of the columns of the filter
        wlength1 = Fh-Pt-1;                                                         // Subset of the rows of the filter
        wlength2 = iprec*wprec-1;                                                   // Number of bit combos
        wlength3 = Fc-1;                                                            // Number of filter sets, but don't really need since countdown will terminate
        wjump0 = wprec*(C*Pr+1);                                                    w_jump0_str = (char*)"Jump to next row of filter set";
        wjump1 = -wprec*(C*Fw*Fh - 1) + wprec*C*Pr + woffset;                       w_jump1_str = (char*)"Move back to start of filter for next bit combo";
        wjump2 = wprec*(C*Pr + 1) + woffset;                                        w_jump2_str = (char*)"Move to next filter set block";
        wjump3 = 0;                                                                 w_jump3_str = (char*)"Not needed!";
        countdown = (C * (Fw-Pr)) * (Fh-Pt) * (iprec * wprec) * (Fc);
        bumpzigzag_on = 2;
        loadshacc_on = 1 << 3;   
    }
    // Lower left corner
    // 
    else if (Pb > 0 && Pl > 0)
    {
        printf("=Lower left corner=\n");
        woffset = wprec*C*Pl;                                                       // Start on weight tile within in the first filter block
        ioffset = iprec*C*W*(H-1-Pb);                                               // Input row position near bottom edge
        ilength0 = C*(Fw-Pl)-1;                                                     // Width of filter window X number of input channel blocks
        ilength1 = Fh-Pb-1;                                                         // Height of filter
        ilength2 = iprec*wprec*Fc-1;                                                // Number of bit combos X number of filter sets
        ilength3 = 0;                                                               // Not needed. Countdown will terminate.
        ijump0 = iprec*(C*(W-Fw+Pl) + 1);                                           i_jump0_str = (char*)"Move to next row";
        ijump1 = -iprec*(C*(Fh-Pb-1)*W + (Fw-Pl)*C - 1);                            i_jump1_str = (char*)"Move back to start of window";
        ijump2 = ijump1;                                                            i_jump2_str = i_jump1_str;
        ijump3 = ijump1;                                                            i_jump3_str = i_jump1_str;
        wlength0 = C*(Fw-Pl)-1;                                                     // One subset of the columns of the filter
        wlength1 = Fh-Pb-1;                                                         // Subset of the rows of the filter
        wlength2 = iprec*wprec-1;                                                   // Number of bit combos
        wlength3 = Fc-1;                                                            // Number of filter sets, but don't really need since countdown will terminate
        wjump0 = wprec*(C*Pl+1);                                                    w_jump0_str = (char*)"Jump to next row of filter set";
        wjump1 = -wprec*(C*Fw*(Fh-Pb) - 1) + woffset;                               w_jump1_str = (char*)"Move back to start of filter for next bit combo";
        wjump2 = wprec*(C*Fw + 1) + woffset;                                        w_jump2_str = (char*)"Move to next filter set block";
        wjump3 = 0;                                                                 w_jump3_str = (char*)"Not needed!";
        countdown = (C * (Fw-Pl)) * (Fh-Pb) * (iprec * wprec) * (Fc);
        bumpzigzag_on = 2;
        loadshacc_on = 1 << 3;    
    }
    // Lower right corner
    else if (Pb > 0 && Pr > 0)
    {

    }
    // Left edge
    else if (Pl > 0)
    {

    }
    // Right edge
    else if (Pr)
    {

    }
    else
    {
        printf("Error! Not a valid padding config!\n");
    }
    
        
}



int main()
{
    w_tptr += woffset;

    // Initialize input tensor
    // The values are set such that each digit represents the position
    // in that dimension of the tensor. This makes reading the print
    // outs easier.
    for (int h=0; h < H; h++)
    {
        for (int w=0; w < W; w++)
        {
            for (int c=0; c < C; c++)
            {
                for (int p=0; p < iprec; p++)
                {
                    i_t[h][w][c][p] = h*m*m*m + w*m*m + c*m + p;
                    //printf("%4d,", i_t[h][w][c][p]);
                }
            }
        }
    }

    // Initialize weight tensor
    // The values are set such that each digit represents the position
    // in that dimension of the tensor. This makes reading the print
    // outs easier.
    for (int fc=0; fc < Fc; fc++)
    {
        for (int fh=0; fh < Fh; fh++)
        {
            for (int fw=0; fw < Fw; fw++)
            {
                for (int c=0; c < C; c++)
                {
                    for (int p=0; p < wprec; p++)
                    {
                        w_t[fc][fh][fw][c][p] = fc*m*m*m*m + fh*m*m*m + fw*m*m + c*m + p;
                        //printf("%5d,", w_t[fc][fh][fw][c][p]);
                    }
                }
                //printf("\n");
            }
        }       
    }

    // Compute parameters for convolution
    //setConv2dlineEdgePadding(1, 0, 1, 0);           // Upper-left corner
    //setConv2dlinevalid();                           // Inner
    setConv2dlineEdgePadding(1, 0, 0, 1);           // Lower-left corner
    assignInternalParams();

    // Print out the computed parameters
    printf("==Computed Parameters==\n");
    printf("ilength0=%10d, ilength1=%10d, ilength2=%10d, ilength3=%10d\n", ilength0, ilength1, ilength2, ilength3);
    printf("ijump0  =%10d, ijump1  =%10d, ijump2  =%10d, ijump3  =%10d\n", ijump0, ijump1, ijump2, ijump3);
    printf("wlength0=%10d, wlength1=%10d, wlength2=%10d, wlength3=%10d\n", wlength0, wlength1, wlength2, wlength3);
    printf("wjump0  =%10d, wjump1  =%10d, wjump2  =%10d, wjump3  =%10d\n", wjump0, wjump1, wjump2, wjump3);
    printf("ioffset=%d, woffset=%d, countdown=%d\n", ioffset, woffset, countdown);
    printf("\n");

    // Do the operation
    int w_whichjump = 0;
    int i_whichjump = 0;
    for (cntdwn = countdown; cntdwn > 0; cntdwn--)
    {
        printf("(%04d,%05d),", *(i_tptr), *(w_tptr));
        i_whichjump = getNextInput();
        w_whichjump = getNextWeight();
        bumpZigZag(w_whichjump);
        genNextOutput(w_whichjump);

    }
    

    printf("\n\nFinal locations: i_tptr=%d, w_tptr=%d\n", *i_tptr, *w_tptr);

    return 0;
}
