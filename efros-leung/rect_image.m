function [output] = rect_image(input_image,ref_y1,ref_x1,ref_y2,ref_x2)
    output = input_image;
    output(ref_x1,ref_y1:ref_y2,1)=1;output(ref_x1,ref_y1:ref_y2,2)=0;output(ref_x1,ref_y1:ref_y2,3)=0;
    output(ref_x2,ref_y1:ref_y2,1)=1;output(ref_x2,ref_y1:ref_y2,2)=0;output(ref_x2,ref_y1:ref_y2,3)=0;
    output(ref_x1:ref_x2,ref_y1,1)=1;output(ref_x1:ref_x2,ref_y1,2)=0;output(ref_x1:ref_x2,ref_y1,3)=0;
    output(ref_x1:ref_x2,ref_y2,1)=1;output(ref_x1:ref_x2,ref_y2,2)=0;output(ref_x1:ref_x2,ref_y2,3)=0;
    
    output(ref_x1+1,ref_y1+1:ref_y2-1,1)=1;output(ref_x1+1,ref_y1+1:ref_y2-1,2)=0;output(ref_x1+1,ref_y1+1:ref_y2-1,3)=0;
    output(ref_x2-1,ref_y1+1:ref_y2-1,1)=1;output(ref_x2-1,ref_y1+1:ref_y2-1,2)=0;output(ref_x2-1,ref_y1+1:ref_y2-1,3)=0;
    output(ref_x1+1:ref_x2-1,ref_y1+1,1)=1;output(ref_x1+1:ref_x2-1,ref_y1+1,2)=0;output(ref_x1+1:ref_x2-1,ref_y1+1,3)=0;
    output(ref_x1+1:ref_x2-1,ref_y2-1,1)=1;output(ref_x1+1:ref_x2-1,ref_y2-1,2)=0;output(ref_x1+1:ref_x2-1,ref_y2-1,3)=0;
    
end

