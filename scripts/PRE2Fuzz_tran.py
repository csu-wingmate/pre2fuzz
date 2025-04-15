import configparser
from os import path

log_file_path = path.join(path.dirname(path.abspath(__file__)), '../config.ini')
config = configparser.ConfigParser()
config.read(log_file_path)

def export(file_path, content):
    with open(file_path, 'a', encoding='utf-8') as file:
        file.write(content + '\n')

LINE1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
LINE2 = "<Peach xmlns=\"http://peachfuzzer.com/2012/Peach\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
LINE3 = "\txsi:schemaLocation=\"http://peachfuzzer.com/2012/Peach ../peach.xsd\">"
LAST_LINE = "</Peach>"

def transform():
    input_file_path = config['base']['input']
    output_file_path = config['base']['output']

    export(output_file_path, LINE1)
    export(output_file_path, LINE2)
    export(output_file_path, LINE3)

    index_of_line = gen_data_model(input_file_path, output_file_path)
    gen_state_model(output_file_path, index_of_line)
    gen_test(output_file_path)
    gen_agent(output_file_path)
    export(output_file_path, LAST_LINE)

def gen_data_model(input_file_path, output_file_path):
    index_of_line = 0
    with open(input_file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
        for line in lines:
            index_of_line += 1
            if index_of_line == 1:
                continue
            last_index_of_comma = line.rfind(',')
            input_data = line[last_index_of_comma + 1:].strip()
            fields = input_data.split()

            export(output_file_path, f"\t<DataModel name=\"DataModel{index_of_line - 1}\">")
            export(output_file_path, "\t\t<Block name=\"Block\">")
            for i, field in enumerate(fields):
                field_length = len(field) * 4  # Assuming hex value length conversion
                export(output_file_path,
                       f"\t\t\t<Number name=\"field{i}\" size=\"{field_length}\" value=\"{field}\" valueType=\"hex\" endian=\"network\" mutable=\"true\" />")
            export(output_file_path, "\t\t</Block>")
            export(output_file_path, "\t</DataModel>")

    return index_of_line

def gen_state_model(file_path, index_of_line):
    export(file_path, "\t<StateModel name=\"StateModel\" initialState=\"State\">")
    export(file_path, "\t\t<State name=\"State\">")
    export(file_path, "\t\t\t<Action type=\"output\">")
    for i in range(1, index_of_line):
        export(file_path, f"\t\t\t\t<DataModel ref=\"DataModel{i}\" />")
    export(file_path, "\t\t\t</Action>")
    export(file_path, "\t\t</State>")
    export(file_path, "\t</StateModel>")

def gen_test(file_path):
    export(file_path, "\t<Test name=\"Default\">")
    export(file_path, "\t\t<Agent ref=\"LinAgent\"/>")
    export(file_path, "\t\t<StateModel ref=\"StateModel\"/>")
    export(file_path, "\t\t<Publisher class=\"TcpClient\" name=\"client\">")
    host = config['sut']['host']
    export(file_path, "\t\t\t<Param name=\"Host\" value=\"" + host + "\"/>")
    port = config['sut']['port']
    export(file_path, "\t\t\t<Param name=\"Port\" value=\"" + port + "\"/>")
    export(file_path, "\t\t</Publisher>")
    export(file_path, "\t\t<Logger class=\"File\">")
    path = config['log']['path']
    export(file_path, "\t\t\t<Param name=\"Path\" value=\"" + path + "\"/>")
    export(file_path, "\t\t</Logger>")
    export(file_path, "\t</Test>")

# todo:
def gen_agent(file_path):
    export(file_path, "\t<Agent name=\"LinAgent\">")
    export(file_path, "\t\t<Monitor class=\"Process\">")
    executable = config['sut']['executable']
    export(file_path, "\t\t\t<Param name=\"Executable\" value=\"" + executable + "\"/>")
    arguments = config['sut']['arguments']
    export(file_path, "\t\t\t<Param name=\"Arguments\" value=\" " + arguments + "\" />")
    export(file_path, "\t\t\t<Param name=\"RestartOnEachTest\" value=\"true\" />")
    export(file_path, "\t\t\t<Param name=\"Faultonearlyexit\" value=\"false\" />")
    export(file_path, "\t\t</Monitor>")
    export(file_path, "\t</Agent>")

if __name__ == "__main__":
    transform()
