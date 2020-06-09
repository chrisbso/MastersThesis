%% Retreieve the indices for the files-cell for which scan correspond to the same head.
%   Thus, numel(headIndices) describes the # of unique heads (discerned by
%   correlation comparison for a given percentile).

%   Note that this contains a cross check, and may give an error if the
%   cross check fails across all heads.
function headIndices = retrieveHeadPairIndices(rMat,rPercentile)
sameAs = cell(length(rMat),2);
headIndices = cell(0);
x = 1:length(rMat);

  for i = 1:length(rMat)
    rVec = rMat(i,:);
    sameAs{i,2} = rVec(rVec>=rPercentile);
    sameAs{i,1} = x(rVec>=rPercentile);
  end
  
  hasChecked = false(1,length(rMat));
  failedTest = false;
  k = 0;
  for i = 1:length(rMat)
      if ~hasChecked(i)
          for j = sameAs{i,1}
                  if ~isequal(sort(sameAs{i,1}),sort(sameAs{j,1}))
                      %error('The discernment was not unique! Try a different rPercentile.')
                      fprintf(['\nCorrelation cross check failed for indices ' num2str(i) ' and ' num2str(j) ',\n']);
                      fprintf(['unionizing file indices [' num2str(sameAs{i,1}) '] and [' num2str(sameAs{j,1}) '].\n']);
                      sameAs{i,1} = union(sameAs{i,1},sameAs{j,1});
                      sameAs{j,1} = union(sameAs{i,1},sameAs{j,1});
                      failedTest = true;
                  end
                  hasChecked(sameAs{j,1}) = true;
          end
          k = k + 1;
          headIndices{k,1} = sameAs{i,1};
      end
  end
  if failedTest
      fprintf('\n WARNING: Some heads are not unique, check the log above!\n');
  else
      fprintf('\n Cross check passed!\n\n');
  end
  
end