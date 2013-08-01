---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module Luna.Codegen.Hs.ModGenerator(
    generateDefinition,
    generateModule
) where


import Debug.Trace

import           Data.String.Utils                 (join)

import qualified Data.Graph.Inductive            as DG
import qualified Luna.Network.Def.DefManager     as DefManager
import           Luna.Network.Def.DefManager       (DefManager)
import qualified Luna.Network.Path.Path          as Path
import qualified Luna.Network.Def.NodeDef        as NodeDef
import           Luna.Network.Def.NodeDef          (NodeDef)
import qualified Luna.Network.Def.Edge           as Edge
import           Luna.Network.Def.Edge             (Edge(..))
import qualified Luna.Type.Type                  as Type
import qualified Luna.Codegen.Hs.Import          as Import
import qualified Luna.Data.Graph                 as Graph

import qualified Luna.Codegen.Hs.AST.Module      as Module
import           Luna.Codegen.Hs.AST.Module        (Module)
import qualified Luna.Codegen.Hs.FuncGenerator   as FG
import qualified Luna.Codegen.Hs.ClassGenerator  as CG
import qualified Luna.Codegen.Hs.Path            as Path
import           Luna.Codegen.Hs.Path              (Path)
import qualified Luna.Codegen.Hs.AST.Function    as Function




generateDefinition :: DefManager -> Graph.Vertex -> Module
generateDefinition manager vtx = code where
    def = Graph.lab manager vtx
    cls = NodeDef.cls def
    code = case cls of
        Type.Module   {} -> mod where
            basemod  = generateModule manager vtx
            submods  = Module.submodules basemod
            subpaths = map Module.path submods
            subimps  = map Import.simple subpaths 
            mod      = basemod {Module.imports = subimps}

        Type.Function {} -> mod where
            basemod  = generateModule manager vtx
            submods  = Module.submodules basemod
            subpaths = map Module.path submods
            subimps  = map Import.qualified subpaths

            subnames = map Path.last subpaths
            subsrcs  = map Path.toModulePath subpaths
            aliases  = [(name, src ++ "." ++ name) | (name, src) <- zip subnames subsrcs]
            basefunc = FG.generateFunction def
            func     = foldr Function.addVarAlias basefunc aliases
            mod      = basemod { Module.imports   = subimps
                               , Module.functions = [func]
                               }

        Type.Class {} -> mod where
            basemod  = generateModule manager vtx
            submods  = Module.submodules basemod
            subpaths = map Module.path submods
            subimps  = map Import.qualified subpaths
            basecls  = CG.generateClass def

            mod      = basemod { Module.imports   = subimps
                               , Module.datatypes = [basecls]
                               }



generateModule :: DefManager -> Graph.Vertex -> Module
generateModule manager vtx  = mod where
    path        = Path.fromList $ DefManager.pathNames manager vtx 
    outnodes    = DefManager.suc manager vtx
    modules     = map (generateDefinition manager) outnodes
    mod         = Module.empty{ Module.path       = path
                              , Module.submodules = modules
                              }

    --outnames    = fmap (Type.name . NodeDef.cls) outnodes
    --outpaths    = fmap ((Path.add path) . Path.single) outnames
    --imports     = zipWith Import.single outpaths outnames
    --importstxt  = join "\n" $ fmap Import.genCode imports
    --header      = "module " ++ Path.toModulePath path
    --out         = header ++ generateModuleReturn ++ importstxt ++ "\n\n"


