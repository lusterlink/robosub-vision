function [ ] = video_to_jpg( filename, number_to_sample, output_dir )
%video_to_jpg This function loads the video from the specifed filename
%   This function load the video from the specified filename and then
%   samples the give number to sample.  It saves the images as bw and
%   scaled down to 640x480.
    video = VideoReader(filename);
    if(video.NumberofFrames < number_to_sample)
        disp('Number of frames is less than sample.');
        return;
    end;
    
    random_vector = randperm(video.NumberofFrames, number_to_sample);
    mkdir(output_dir);
    
    for i=1:length(random_vector)
        color_full_pic = read(video, random_vector(i));
        color_scaled_pic = imresize(color_full_pic, [480 640]);
        grey_scale = rgb2gray(color_scaled_pic);
        output_file_name = [output_dir filesep sprintf('%d', i) '.jpg']; 
        imwrite(grey_scale, output_file_name, 'jpg');
    end;

end

