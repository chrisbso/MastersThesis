function MIDs = getMIDsForRFshim(currDir)
MIDsListing = dir([currDir slsh '*_dt_dream*.dat']);
MIDsListing = extractBetween(MIDsListing(1).name,'MID','_dt_dream');
MIDs = str2num(MIDsListing{1});
end