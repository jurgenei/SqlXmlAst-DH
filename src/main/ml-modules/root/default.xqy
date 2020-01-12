xquery version "1.0-ml";
xdmp:set-response-content-type("text/html"),
('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
<html xmlns="https://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <title>My first Mark Logic web page</title>
    </head>
    <body>
        <p>Hello World! This application is running on MarkLogic Server version {xdmp:version()}</p>
    </body>
</html>)
