@echo off
rem Starts a small local web server and opens the LociStoa prototype in your browser.
rem Needs Python installed. Close this window to stop the server.
start "" http://localhost:8000
python -m http.server 8000
