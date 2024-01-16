function sms_messages(test, fnTextMessages)
arguments
    test logical = false
    fnTextMessages string = "message_text.txt"
end
pwd
cd(fileparts(mfilename('fullpath')))    % cd to current file, just in case

%% messages
messages = readlines(fnTextMessages);

% Day 1  - 20:00
msg1N = messages(1);
% Day 2-7 - 20:00
msg2N = messages(2);
% Morning reminder - 6:00
msgE = messages(3);
%% code

xlxFilename = "ESMLog.xlsx";
opts = detectImportOptions(xlxFilename,'Sheet','experience sampling links');
opts.VariableTypes(2:end-2) = {'string'};
T = readtable(xlxFilename,opts,'Sheet','experience sampling links');

% this is fake me checking to get a fake sms, making sure it works
T.Start(T.ID == 0) = datetime('yesterday', 'Format','default','InputFormat','yyyy-MM-dd');
T.End(T.ID == 0) = datetime('tomorrow', 'Format','default','InputFormat','yyyy-MM-dd');

T(isnat(T.Start),:) = [];
T(days(datetime('today') - T.End) > 0 ,:) = [];
%%
allIDs = unique(T.ID)';

if test % test it on me
    allIDs = 0;
end
for thisID = allIDs
    thisParent = T.ID == thisID;
    thisPhone = T.phone_(thisParent);
    link_ = T.questionnaireLink(thisParent);
    if strlength(thisPhone) == 8
        thisPhone = "+45" + thisPhone;
    elseif startsWith(thisPhone) == "+"
        % do nothing
    elseif strlength(thisPhone) == 11
        thisPhone = "+" + thisPhone;
    else
        warning("something wrong, check phone of id " + thisID)
    end

    % case 1: send at 20:00 @FIRST day
    if ~isnat(T.Start(thisParent)) &&...                            % make sure the subject has already come
            T.Start(thisParent) == datetime('today') && ...         % --------------------- started today
            (hours(datetime('now') - datetime('today')) - 20) < 1         % ---------- we go with the evening batch (added check)
        cmd = sprintf("osascript ./sendsms.scpt ""%s"" """ + msg1N + """", thisPhone, link_)
        system(cmd)
        % case 2: send at 6:30 @EVERY day
    elseif ~isnat(T.Start(thisParent)) &&...
            datetime('today') > T.Start(thisParent) &&...
            (hours(datetime('now') - datetime('today')) - 6.5) < 1 &&...        %
            T.End(thisParent) >= datetime('today')                      % make sure we are not done
        cmd = sprintf("osascript ./sendsms.scpt ""%s"" ""%s""", thisPhone, msgE)
        system(cmd)
        % case 3: send at 20:00 @2-END day
    elseif ~isnat(T.Start(thisParent)) &&...
            datetime('today') > T.Start(thisParent) &&...
            (hours(datetime('now') - datetime('today')) - 20) < 1 &&...        %
            T.End(thisParent) > datetime('today')                      % make sure we are not done
        cmd = sprintf("osascript ./sendsms.scpt ""%s"" """ + msg2N + """", thisPhone, link_)
        system(cmd)
    end
end

