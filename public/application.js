var editor = ace.edit('editor');

editor.renderer.setShowPrintMargin(false);
editor.renderer.setShowGutter(false);
editor.setShowFoldWidgets(false);
editor.setDisplayIndentGuides(false);
editor.setHighlightActiveLine(false);
editor.setHighlightSelectedWord(false);

// Disable gotoline
editor.commands.addCommands([{
    name: "gotoline",
    bindKey: {win: "Ctrl-L", mac: "Command-L"},
    exec: function(editor, line) {
        return false;
    },
    readOnly: true
}]);

$('#json').val(editor.getSession().getValue());
editor.getSession().on('change', function(){
    $('#json').val(editor.getSession().getValue());
});

var JSONMode = require("ace/mode/json").Mode;
editor.getSession().setMode(new JSONMode());

editor.setTheme("ace/theme/twilight");

$('#editor').css('font-size', '16px').css('line-height', '140%');
