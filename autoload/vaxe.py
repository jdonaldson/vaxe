import vim, re, HTMLParser
import xml.etree.ElementTree as ET

complete_output = vim.eval("complete_output")
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

vim.command("let output = " + str(completes))
