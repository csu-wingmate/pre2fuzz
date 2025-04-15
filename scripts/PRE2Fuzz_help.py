#!/usr/bin/env python3

def print_help():
    help_text = """shared arguments:
  -o SAVETO, --saveto SAVETO
                                                       path to keep the results

pre arguments:
  -i TRAFFIC, --traffic TRAFFIC
                                                       network traffic file
  -r REVERSE_TOOL, --reverse_tool REVERSE_TOOL
                                                       name of the reverse tool

generation arguments:
  -fi FORMAT_INFERENCE, --format_inference FORMAT_INFERENCE
                                                       format inference result file
  -mo MESSAGE_ORDER, --message_order MESSAGE_ORDER
                                                       message order information file
  -md MESSAGE_DIRECTION, --message_direction MESSAGE_DIRECTION
                                                       message direction information file

fuzz arguments:
  -p PROTOCOL, --protocol PROTOCOL
                                                       name of the protocol implementation
  -f FUZZER, --fuzzer FUZZER
                                                       name of the fuzzer
  -x TEST_TEMPLATE, --test_template TEST_TEMPLATE
                                                       test template file
  -t TIMEOUT, --timeout TIMEOUT
                                                       time for fuzzing
    """
    print(help_text)

if __name__ == "__main__":
    print_help()
