filename = "bad.gif";


gifinfo = imfinfo(filename);
delaytimes = [gifinfo.DelayTime] / 100;
numFrames = length(delaytimes);
frameHeight = [gifinfo.Height];
frameWidth = [gifinfo.Width];

ratio = double(frameHeight(1)) / double(frameWidth(1));

if ratio < 1
    width = 400;
    height = floor(width * ratio);
else
    height = 400;
    width = floor(height / ratio);
end


[frames,map] = imread(filename, 'frames','all');

hashes = zeros(50,50,3,numFrames);

for idx = 1:numFrames
    temp = imresize(ind2rgb(frames(:,:,:,idx), map) , [50,50],'bilinear');
    temp2 = uint8(floor(temp * 255));
    hashes(:,:,:,idx) = temp2 - mod(temp2,128);
end

tolerance = 100;

loopList = [];
start_suspect = 1;
while start_suspect < numFrames
    end_suspect = start_suspect +5;
    while end_suspect < numFrames

        if nnz(hashes(:,:,:,start_suspect) - hashes(:,:,:,end_suspect)) < tolerance
            % LOOP FOUND
            loopList = [loopList; start_suspect, end_suspect];
            loop_break = numFrames;
            while loop_break > end_suspect
                if nnz(hashes(:,:,:,start_suspect) - hashes(:,:,:,loop_break)) < tolerance
                    % LOOP END FOUND
                    break;
                end
                loop_break = loop_break - 1;
            end
            start_suspect = loop_break;
            break;
        end

        end_suspect = end_suspect +1;
    end
    start_suspect = start_suspect +1;
end

%%

loop_number =1;
renderName = "bad1.gif";

idx = loopList(loop_number,1);

currentFrame = frames(:,:,:,idx);

resizedFrame = imresize(currentFrame, [height, width], 'nearest');

imwrite(resizedFrame,map,renderName,"gif","LoopCount",Inf,"DelayTime",delaytimes(idx));



for idx = (loopList(loop_number,1)+1):(loopList(loop_number,2)-1)
    currentFrame = frames(:,:,:,idx);
    resizedFrame = imresize(currentFrame, [height, width], 'nearest');
    imwrite(resizedFrame,map,renderName,"gif","WriteMode","append","DelayTime",delaytimes(idx));

end