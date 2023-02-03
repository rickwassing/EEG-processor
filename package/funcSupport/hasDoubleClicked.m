function bool = hasDoubleClicked(app)
% ---------------------------------------------------------
% Check if we have a double click or not
if (now-app.LastClick)*24*60*60*1000 > 500
    bool = false;
else
    bool = true;
end
app.LastClick = now;
datestr(app.LastClick)
end
