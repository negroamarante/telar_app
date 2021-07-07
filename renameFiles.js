var fs = require('fs');
var path = require('path');
// In newer Node.js versions where process is already global this isn't necessary.
var process = require("process");

var moveFrom = "force-app/main/default/classes";

// Loop through all the files in the temp directory
fs.readdir(moveFrom, function (err, files) {
  if (err) {
    console.error("Could not list the directory.", err);
    process.exit(1);
  }

  files.forEach(function (file, index) {
        var newFile = file.replace('fflib_', '')
        var fromPath = path.join(moveFrom, file);
        var toPath = path.join(moveFrom, newFile);
        
        console.log(fromPath + ' to -> '+toPath);
      
      fs.rename(fromPath, toPath, function (error) {
        if (error) throw error;
        console.log('File Renamed.');
      });
  });
});