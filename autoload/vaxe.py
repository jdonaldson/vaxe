import vim, re, HTMLParser
import xml.etree.ElementTree as ET
import json

# This is the python portion of the completion script.  Call it with the *name*
# of the input vimscript variable, "complete_output_var".  This should contain
# the output from the --display compiler directive.  The output is given in
# "output_var", which is likewise the name of the vimscript variable to write.
# This variable contains a dictionary formatted appropriately for an omnifunc.
def complete(complete_output_var, output_var, base_var):
    complete_output = vim.eval(complete_output_var)
    base = vim.eval(base_var)
    if complete_output is None: complete_output = ''
    completes = []

    # wrap in a tag to prevent parsing errors
    root= ET.XML("<output>"+complete_output+"</output>")

    fields = root.findall("list/i")
    types = root.findall("type")
    completes = []

    if len(fields) > 0:
        def fieldxml2completion(x):
            word = x.attrib["n"]
            menu = x.find("t").text
            info = x.find("d").text
            menu = '' if menu is None else menu
            if info is None:
                info = ['']
            else:
                # get rid of leading/trailing ws/nl
                info = info.strip()
                # split and collapse extra whitespace
                info = [re.sub(r'\s+',' ',s.strip()) for s in info.split('\n')]

            abbr = word
            kind = 'v'
            if  menu == '': kind = 'm'
            elif re.search("\->", menu): kind = 'f' # if it has a ->
            return {  'word': word, 'info': info, 'kind': kind
                    ,'menu': menu, 'abbr': abbr, 'dup':1 }
        completes = map(fieldxml2completion, fields)
    elif len(types) > 0:
        otype = types[0]
        h = HTMLParser.HTMLParser()
        word = ' '
        info = [h.unescape(otype.text).strip()]
        abbr = info[0]
        completes= [{'word':word,'info':info, 'abbr':abbr, 'dup':1}]

    completes = [c for c in completes if re.search("^" + base, c['word'])]
    vim.command("let " + output_var + " = " + json.dumps(completes))

