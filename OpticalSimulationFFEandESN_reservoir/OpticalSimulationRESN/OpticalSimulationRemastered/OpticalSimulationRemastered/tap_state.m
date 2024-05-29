function stateCollection_tapped = tap_state(stateCollection,taps)

   

        
        
        numRows = size(stateCollection, 1);
        numColums = size(stateCollection,2);

        
        %Symbols due to dispersion
        
        tap_range = 1:taps;
    
        m = floor((1 + taps) / 2);
        tap_range = tap_range - m;
        
       
    
    
        stateCollection_tapped= zeros(numRows* taps,numColums);
        
      
        
        for i = m:numRows - m
            surrounding_elements = stateCollection(i + tap_range, :);
            vector = reshape(surrounding_elements.', [], 1);
            start_index = (i - m) * taps + 1;
            end_index = start_index + taps - 1;
            stateCollection_tapped(start_index:end_index, :) = vector;
        end
  
       

end
