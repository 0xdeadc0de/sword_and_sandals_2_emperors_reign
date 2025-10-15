meta:
  id: example
  endian: be   # or le, depending on context
seq:
  - id: skip1
    size: 6
    
  - id: magic_sol
    contents: "TCSO"
    
  - id: sol_version
    type: u2
    
  - id: skip2
    size: 4
    
  - id: ss2_data
    type: key_name
    
  - id: skip3
    size: 4
    
  - id: so_local_value
    type: amf_kv
    
    
types:
  amf_value:
    seq:
    - id: index
      type: u1
    - id: value
      type:
        switch-on: index
        cases:
          0x00: amf_number
          0x02: amf_string
          0x03: amf_object
          0x08: amf_array
      
  amf_number:
    seq:
    - id: value
      type: f8
      
  amf_object:
    seq:
    - id: kvs
      type: amf_kv
      repeat: until
      repeat-until: _.key.length == 0
      
  amf_array:
    seq:
    - id: length
      type: u4
    - id: items
      type: amf_kv
      repeat: expr
      repeat-expr: length
    - id: end
      contents: [0x00, 0x00, 0x09]
      
  amf_kv:
    seq:
    - id: key
      type: key_name
    - id: value
      type: amf_value
      
  key_name:
    seq:
      - id: length
        type: u2
      - id: data
        type: str
        size: length
        encoding: UTF-8
      
  amf_string:
    seq:
      - id: text
        type: key_name