%% Get the MIDs from DREAM and 3DEGRE
function MIDs = getMIDsForKTshim(parentDir)
MIDsListing = dir([parentDir slsh '*_dt_dream*.dat']);
MIDsListing = extractBetween(MIDsListing(1).name,'MID','_dt_dream');
MIDs = str2num(MIDsListing{1});
MIDsListing = dir([parentDir slsh '*fieldmap*.dat']);
MIDsListing = extractBetween(MIDsListing(1).name,'MID','_dt_fieldmap');
MIDs = [MIDs str2num(MIDsListing{1})];
end