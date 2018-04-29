function [output_image, filled_map] = generate_filled_map(input_image,mask_image )
output_image = input_image;

temp = output_image(:,:,1);
temp(mask_image==1)=0;
output_image(:,:,1)=temp;

temp = output_image(:,:,2);
temp(mask_image==1)=0;
output_image(:,:,2)=temp;

temp = output_image(:,:,3);
temp(mask_image==1)=0;
output_image(:,:,3)=temp;


filled_map = true(size(mask_image));
filled_map(mask_image==1)=0;
end

