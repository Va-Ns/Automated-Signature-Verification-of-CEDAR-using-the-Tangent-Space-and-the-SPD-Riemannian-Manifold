function nvc=conv2vec_with_logm(vc)
vc = logm(vc);
k=0;
for i=1:size(vc,1)
    for j=i:size(vc,1)
        k = k+1;
        if i == j
            nvc(k)=vc(i,j);
        else
            nvc(k) = vc(i,j)*sqrt(2);
            % nvc(k)=vc(i,j);
        end
    end
end
            