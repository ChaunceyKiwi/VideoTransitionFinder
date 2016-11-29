function [image, houghImg, edgeCounter] = findEdge(res, threshold)

% show result
miniLength = size(res,1) * 0.7;
imagePro = res < threshold;
figure('Visible', 'off');
BW = edge(imagePro,'canny');
[H,T,R] = hough(BW);
imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);
P  = houghpeaks(H,1,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
h = getframe;
houghImg = h.cdata;
hold off
lines = houghlines(BW,T,R,P,'FillGap',60,'MinLength',miniLength);
edgeCounter = length(lines);
imshow(res);
hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',1/2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','MarkerSize', 1/2,'LineWidth',1/2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','MarkerSize', 1/2,'LineWidth',1/2,'Color','red');
end
h = getframe;
image = h.cdata;
hold off