/**
 * Autogenerated by Thrift Compiler (0.9.0)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */
#ifndef defs_TYPES_H
#define defs_TYPES_H

#include <thrift/Thrift.h>
#include <thrift/TApplicationException.h>
#include <thrift/protocol/TProtocol.h>
#include <thrift/transport/TTransport.h>

#include "attrs_types.h"
#include "graph_types.h"
#include "libs_types.h"
#include "types_types.h"


namespace flowbox { namespace batch { namespace defs {

typedef int32_t DefID;

typedef std::vector<class Import>  Imports;

typedef struct _Import__isset {
  _Import__isset() : path(false), name(false) {}
  bool path;
  bool name;
} _Import__isset;

class Import {
 public:

  static const char* ascii_fingerprint; // = "C6BDC91060F17E46D86CE1794BF33C1A";
  static const uint8_t binary_fingerprint[16]; // = {0xC6,0xBD,0xC9,0x10,0x60,0xF1,0x7E,0x46,0xD8,0x6C,0xE1,0x79,0x4B,0xF3,0x3C,0x1A};

  Import() : name() {
  }

  virtual ~Import() throw() {}

  std::vector<std::string>  path;
  std::string name;

  _Import__isset __isset;

  void __set_path(const std::vector<std::string> & val) {
    path = val;
    __isset.path = true;
  }

  void __set_name(const std::string& val) {
    name = val;
    __isset.name = true;
  }

  bool operator == (const Import & rhs) const
  {
    if (__isset.path != rhs.__isset.path)
      return false;
    else if (__isset.path && !(path == rhs.path))
      return false;
    if (__isset.name != rhs.__isset.name)
      return false;
    else if (__isset.name && !(name == rhs.name))
      return false;
    return true;
  }
  bool operator != (const Import &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Import & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Import &a, Import &b);

typedef struct _Definition__isset {
  _Definition__isset() : cls(false), imports(true), flags(true), attribs(true), defID(true) {}
  bool cls;
  bool imports;
  bool flags;
  bool attribs;
  bool defID;
} _Definition__isset;

class Definition {
 public:

  static const char* ascii_fingerprint; // = "5ADBA4014C5034CFF53DD292BCEF0C81";
  static const uint8_t binary_fingerprint[16]; // = {0x5A,0xDB,0xA4,0x01,0x4C,0x50,0x34,0xCF,0xF5,0x3D,0xD2,0x92,0xBC,0xEF,0x0C,0x81};

  Definition() : defID(-1) {



  }

  virtual ~Definition() throw() {}

   ::flowbox::batch::types::Type cls;
  Imports imports;
   ::flowbox::batch::attrs::Flags flags;
   ::flowbox::batch::attrs::Attributes attribs;
  DefID defID;

  _Definition__isset __isset;

  void __set_cls(const  ::flowbox::batch::types::Type& val) {
    cls = val;
    __isset.cls = true;
  }

  void __set_imports(const Imports& val) {
    imports = val;
    __isset.imports = true;
  }

  void __set_flags(const  ::flowbox::batch::attrs::Flags& val) {
    flags = val;
    __isset.flags = true;
  }

  void __set_attribs(const  ::flowbox::batch::attrs::Attributes& val) {
    attribs = val;
    __isset.attribs = true;
  }

  void __set_defID(const DefID val) {
    defID = val;
    __isset.defID = true;
  }

  bool operator == (const Definition & rhs) const
  {
    if (__isset.cls != rhs.__isset.cls)
      return false;
    else if (__isset.cls && !(cls == rhs.cls))
      return false;
    if (__isset.imports != rhs.__isset.imports)
      return false;
    else if (__isset.imports && !(imports == rhs.imports))
      return false;
    if (__isset.flags != rhs.__isset.flags)
      return false;
    else if (__isset.flags && !(flags == rhs.flags))
      return false;
    if (__isset.attribs != rhs.__isset.attribs)
      return false;
    else if (__isset.attribs && !(attribs == rhs.attribs))
      return false;
    if (__isset.defID != rhs.__isset.defID)
      return false;
    else if (__isset.defID && !(defID == rhs.defID))
      return false;
    return true;
  }
  bool operator != (const Definition &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const Definition & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(Definition &a, Definition &b);

typedef struct _DEdge__isset {
  _DEdge__isset() : src(false), dst(false) {}
  bool src;
  bool dst;
} _DEdge__isset;

class DEdge {
 public:

  static const char* ascii_fingerprint; // = "C1241AF5AA92C586B664FD41DC97C576";
  static const uint8_t binary_fingerprint[16]; // = {0xC1,0x24,0x1A,0xF5,0xAA,0x92,0xC5,0x86,0xB6,0x64,0xFD,0x41,0xDC,0x97,0xC5,0x76};

  DEdge() : src(0), dst(0) {
  }

  virtual ~DEdge() throw() {}

  DefID src;
  DefID dst;

  _DEdge__isset __isset;

  void __set_src(const DefID val) {
    src = val;
    __isset.src = true;
  }

  void __set_dst(const DefID val) {
    dst = val;
    __isset.dst = true;
  }

  bool operator == (const DEdge & rhs) const
  {
    if (__isset.src != rhs.__isset.src)
      return false;
    else if (__isset.src && !(src == rhs.src))
      return false;
    if (__isset.dst != rhs.__isset.dst)
      return false;
    else if (__isset.dst && !(dst == rhs.dst))
      return false;
    return true;
  }
  bool operator != (const DEdge &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const DEdge & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(DEdge &a, DEdge &b);

typedef struct _DefsGraph__isset {
  _DefsGraph__isset() : defs(false), edges(false) {}
  bool defs;
  bool edges;
} _DefsGraph__isset;

class DefsGraph {
 public:

  static const char* ascii_fingerprint; // = "35EB8A29C79B338AB1F79CF0229023E2";
  static const uint8_t binary_fingerprint[16]; // = {0x35,0xEB,0x8A,0x29,0xC7,0x9B,0x33,0x8A,0xB1,0xF7,0x9C,0xF0,0x22,0x90,0x23,0xE2};

  DefsGraph() {
  }

  virtual ~DefsGraph() throw() {}

  std::map<DefID, Definition>  defs;
  std::vector<DEdge>  edges;

  _DefsGraph__isset __isset;

  void __set_defs(const std::map<DefID, Definition> & val) {
    defs = val;
    __isset.defs = true;
  }

  void __set_edges(const std::vector<DEdge> & val) {
    edges = val;
    __isset.edges = true;
  }

  bool operator == (const DefsGraph & rhs) const
  {
    if (__isset.defs != rhs.__isset.defs)
      return false;
    else if (__isset.defs && !(defs == rhs.defs))
      return false;
    if (__isset.edges != rhs.__isset.edges)
      return false;
    else if (__isset.edges && !(edges == rhs.edges))
      return false;
    return true;
  }
  bool operator != (const DefsGraph &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const DefsGraph & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(DefsGraph &a, DefsGraph &b);

typedef struct _DefManager__isset {
  _DefManager__isset() : defs(false), graphs(false), edges(false) {}
  bool defs;
  bool graphs;
  bool edges;
} _DefManager__isset;

class DefManager {
 public:

  static const char* ascii_fingerprint; // = "47CB96C55C56A168FAE4616D5BA09560";
  static const uint8_t binary_fingerprint[16]; // = {0x47,0xCB,0x96,0xC5,0x5C,0x56,0xA1,0x68,0xFA,0xE4,0x61,0x6D,0x5B,0xA0,0x95,0x60};

  DefManager() {
  }

  virtual ~DefManager() throw() {}

  std::vector<Definition>  defs;
  std::vector< ::flowbox::batch::graph::Graph>  graphs;
  std::vector<DEdge>  edges;

  _DefManager__isset __isset;

  void __set_defs(const std::vector<Definition> & val) {
    defs = val;
    __isset.defs = true;
  }

  void __set_graphs(const std::vector< ::flowbox::batch::graph::Graph> & val) {
    graphs = val;
    __isset.graphs = true;
  }

  void __set_edges(const std::vector<DEdge> & val) {
    edges = val;
    __isset.edges = true;
  }

  bool operator == (const DefManager & rhs) const
  {
    if (__isset.defs != rhs.__isset.defs)
      return false;
    else if (__isset.defs && !(defs == rhs.defs))
      return false;
    if (__isset.graphs != rhs.__isset.graphs)
      return false;
    else if (__isset.graphs && !(graphs == rhs.graphs))
      return false;
    if (__isset.edges != rhs.__isset.edges)
      return false;
    else if (__isset.edges && !(edges == rhs.edges))
      return false;
    return true;
  }
  bool operator != (const DefManager &rhs) const {
    return !(*this == rhs);
  }

  bool operator < (const DefManager & ) const;

  uint32_t read(::apache::thrift::protocol::TProtocol* iprot);
  uint32_t write(::apache::thrift::protocol::TProtocol* oprot) const;

};

void swap(DefManager &a, DefManager &b);

}}} // namespace

#endif
