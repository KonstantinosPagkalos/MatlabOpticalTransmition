function stateCollection_tapped = tap(stateCollection,taps)

        

        

        numRows = size(stateCollection, 1);
        numColums = size(stateCollection,2);
        
        n_ignore = 1000;
        
        %Symbols due to dispersion
        
        tap_range = 1:taps;
    
        m = floor((1 + taps) / 2);
        tap_range = tap_range - m;
        
       
        stateCollection = stateCollection';
    
    
        stateCollection_tapped= zeros(numColums * taps, numRows);
        
      
        
        for i = m:numRows - m
            surrounding_elements = stateCollection(:, i + tap_range);
            vector = reshape(surrounding_elements, 1, taps * numColums);
            stateCollection_tapped(:, i) = vector;
        end
    
        stateCollection_tapped = stateCollection_tapped(:,n_ignore:end - n_ignore);
        
       stateCollection_tapped = stateCollection_tapped';
       

end       