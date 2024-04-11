function VecsOnTP = VecCell(SignStruct)

    arguments(Input) 
        
        SignStruct {mustBeUnderlyingType(SignStruct,"struct")}

    end

    [numWriter, numSignature] = size(SignStruct);
    
    VecsOnTP = cell(numWriter,numSignature);

    for Writer = 1 : numWriter

        for Signature = 1 : numSignature

            getCov = SignStruct(Writer,Signature).cov(1).cov;
            prodVec = VecsOfTangentPlaneNV(getCov);
            VecsOnTP{Writer,Signature} = prodVec';

        end

    end

end