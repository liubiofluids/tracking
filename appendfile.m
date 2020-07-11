function result=appendfile(data, FileName)
fid=fopen(FileName, 'r+');
if fid==-1
fid=fopen(FileName, 'w');
end
fseek(fid, 0, 1);
dim=size(data);
for i=1 :dim(1)
for j=1 :dim(2)
fprintf(fid, '%f\t', data(i,j));
end
fprintf(fid, '\n');
end
fclose(fid);
result=1;
