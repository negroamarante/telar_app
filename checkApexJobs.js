const exec = require("child_process").exec;

function getTotalSize(stdout) {
    var jsonQuery = JSON.parse(stdout);
    return JSON.stringify(jsonQuery.result.totalSize);
}

execute("sfdx force:data:soql:query --json -q \"SELECT Id FROM AsyncApexJob WHERE Status != 'Completed' AND ApexClass.name like '%FileObjectDataLoaderBatchProcessor'\" ", function repeat(stdout, stderr){
    console.log(' ==============2 hora ' +Date(Date.now()));
    setTimeout(function() {
        console.log(' ==============3 hora ' +Date(Date.now()));
        execute("sfdx force:data:soql:query --json -q \"SELECT Id FROM AsyncApexJob WHERE Status != 'Completed' AND ApexClass.name like '%FileObjectDataLoaderBatchProcessor'\" ", repeat);
    }, 4000);
})

function execute(command, callback) {
    console.log(' ==============1 hora ' +Date(Date.now()));
    exec(command, function(error, stdout, stderr) {
        //Si tiene Jobs incompletos => vuelvo a ejecutar en xxxx segundos
        console.log('Tamaño => '+getTotalSize(stdout));
        if( getTotalSize(stdout) > 0 ){
            console.log('Tiene q volver a correr ');
            callback(command, callback);
        } else {
            console.log('No tiene jobs puede comenzar');
            // init();
        }
    });
}