(library
  (harlan verification-passes)
  (export
    verify-harlan
    verify-nest-lets
    verify-parse-harlan
    verify-returnify
    verify-typecheck
    verify-expand-primitives
    verify-make-kernel-dimensions-explicit
    verify-lift-complex
    verify-remove-nested-kernels
    verify-returnify-kernels
    verify-make-vector-refs-explicit
    verify-annotate-free-vars
    verify-insert-let-regions
    verify-infer-regions
    verify-uglify-vectors
    verify-remove-let-regions
    verify-flatten-lets
    verify-hoist-kernels
    verify-generate-kernel-calls
    verify-compile-module
    verify-convert-types)
  (import
    (rnrs)
    (harlan helpers)
    (elegant-weapons helpers)
    (util verify-grammar))

(grammar-transforms

  (%static
    (Type
      harlan-type
      (vec Type)
      (ptr Type)
      ((Type *) -> Type))
    (C-Type
      harlan-c-type
      harlan-cl-type
      (ptr C-Type)
      (const-ptr C-Type)
      ((C-Type *) -> C-Type)
      Type)
    (Var ident)
    (Integer integer)
    (Reduceop reduceop)
    (Binop binop)
    (Relop relop)
    (Float float)
    (String string)
    (Char char)
    (Boolean boolean)
    (Number number))
  
  (harlan
    (Start Module)
    (Module (module Decl +))
    (Decl
      (extern Var (Type *) -> Type)
      (fn Var (Var *) Value +) ;; depricated, use define instead
      (define (Var Var *) Value +))
    (Value
      char
      integer
      boolean
      float
      string
      ident
      (let Var Value)
      (let ((Var Value) *) Value +)
      (begin Value * Value)
      (print Value)
      (print Value Value)
      (write-pgm Value Value)
      (assert Value)
      (set! Var Value)
      (for (Var Value Value) Value +)
      (for (Var Value Value Value) Value +)
      (while Value Value +)
      (if Value Value)
      (if Value Value Value)
      (return)
      (return Value)
      (var Var) ;; depricated, vars do not need tags
      (vector Value +)
      (vector-ref Value Value)
      (kernel ((Var Value) +) Value * Value)
      (reduce Reduceop Value)
      (iota Value)
      (length Value)
      (make-vector Value Value)
      (Binop Value Value)
      (Relop Value Value)
      (Var Value *)))

  (nest-lets (%inherits Module Decl)
    (Start Module)
    (Value
      char
      integer
      boolean
      float
      string
      ident
      (let ((Var Value) *) Value +)
      (begin Value * Value)
      (print Value)
      (print Value Value)
      (write-pgm Value Value)
      (assert Value)
      (set! Value Value)
      (vector-set! Value Value Value)
      (for (Var Value Value) Value +)
      (for (Var Value Value Value) Value +)
      (while Value Value +)
      (if Value Value)
      (if Value Value Value)
      (return Value)
      (var Var)
      (vector Value +)
      (vector-ref Value Value)
      (kernel ((Var Value) +) Value +)
      (reduce Reduceop Value)
      (iota Value)
      (length Value)
      (make-vector Value Value)
      (Binop Value Value)
      (Relop Value Value)
      (Var Value *)))

  (parse-harlan (%inherits Module)
    (Start Module)
    (Decl
      (extern Var (Type *) -> Type)
      (fn Var (Var *) Stmt))
    (Stmt
      (let ((Var Expr) *) Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (begin Stmt * Stmt)
      (print Expr)
      (print Expr Expr)
      (write-pgm Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (vector-set! Expr Expr Expr)
      (do Expr)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (return)
      (return Expr))
    (Expr
      (char Char)
      (num Integer)
      (float Float)
      (str String)
      (bool Boolean)
      (var Var)
      (vector Expr +)
      (begin Stmt * Expr)
      (if Expr Expr Expr)
      (vector-ref Expr Expr)
      (let ((Var Expr) *) Expr)
      (kernel ((Var Expr) +) Expr)
      (reduce Reduceop Expr)
      (iota Expr)
      (length Expr)
      (int->float Expr)
      (make-vector Expr)
      (Binop Expr Expr)
      (Relop Expr Expr)
      (call Var Expr *)))

  (returnify (%inherits Module)
    (Start Module)
    (Decl
      (fn Var (Var *) Body)
      (extern Var (Type *) -> Type))
    (Body
      (begin Stmt * Body)
      (let ((Var Expr) *) Body)
      (if Expr Body)
      (if Expr Body Body)
      Ret-Stmt)
    (Ret-Stmt (return Expr) (return))
    (Stmt
      (let ((Var Expr) *) Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (begin Stmt * Stmt)
      (print Expr)
      (print Expr Expr)
      (write-pgm Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (vector-set! Expr Expr Expr)
      (do Expr)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      Ret-Stmt)
    (Expr
      (char Char)
      (bool Boolean)
      (num Integer)
      (float Float)
      (str String)
      (var Var)
      (vector Expr +)
      (begin Stmt * Expr)
      (if Expr Expr Expr)
      (vector-ref Expr Expr)
      (let ((Var Expr) *) Expr)
      (kernel ((Var Expr) +) Expr)
      (reduce Reduceop Expr)
      (iota Expr)
      (length Expr)
      (int->float Expr)
      (make-vector Expr)
      (Binop Expr Expr)
      (Relop Expr Expr)
      (call Var Expr *)))

  (typecheck (%inherits Module Ret-Stmt)
    (Start Module)
    (Decl
      (extern Var (Type *) -> Type)
      (fn Var (Var *) Type Body))
    (Body
      (begin Stmt * Body)
      (let ((Var Type Expr) *) Body)
      (if Expr Body)
      (if Expr Body Body)
      Ret-Stmt)
    (Stmt
      (let ((Var Type Expr) *) Stmt)
      (if Expr Stmt)
      (begin Stmt * Stmt)
      (if Expr Stmt Stmt)
      (print Type Expr)
      (print Type Expr Expr)
      (write-pgm Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (vector-set! Type Expr Expr Expr)
      (do Expr)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (return Expr))
    (Expr
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (bool Boolean)
      (var Type Var)
      (if Expr Expr Expr)
      (let ((Var Type Expr) *) Expr)
      (begin Stmt * Expr)
      (vector Type Expr +)
      (vector-ref Type Expr Expr)
      (kernel Type (((Var Type) (Expr Type)) +) Expr)
      (reduce Type Reduceop Expr)
      (iota Expr)
      (length Expr)
      (int->float Expr)
      (make-vector Type Expr)
      (Binop Type Expr Expr)
      (Relop Type Expr Expr)
      (call Expr Expr *)))

  (expand-primitives
    (%inherits Module Decl Body Ret-Stmt)
    (Start Module)
    (Stmt
      (let ((Var Type Expr) *) Stmt)
      (if Expr Stmt)
      (begin Stmt * Stmt)
      (if Expr Stmt Stmt)
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (vector-set! Type Expr Expr Expr)
      (do Expr)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (return Expr))
    (Expr
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (bool Boolean)
      (var Type Var)
      (if Expr Expr Expr)
      (let ((Var Type Expr) *) Expr)
      (begin Stmt * Expr)
      (vector-ref Type Expr Expr)
      (kernel Type (((Var Type) (Expr Type)) +) Expr)
      (length Expr)
      (int->float Expr)
      (make-vector Type Expr)
      (Binop Expr Expr)
      (Relop Expr Expr)
      (call Expr Expr *)))
  
  (make-kernel-dimensions-explicit
    (%inherits Module Decl Body Stmt Ret-Stmt)
    (Start Module)
    (Expr
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (bool Boolean)
      (var Type Var)
      (if Expr Expr Expr)
      (let ((Var Type Expr) *) Expr)
      (begin Stmt * Expr)
      (vector-ref Type Expr Expr)
      (kernel Type (Expr +) (((Var Type) (Expr Type) Integer) +) Expr)
      (length Expr)
      (int->float Expr)
      (make-vector Type Expr)
      (Binop Expr Expr)
      (Relop Expr Expr)
      (call Expr Expr *)))
  
  (lift-complex (%inherits Module Decl)
    (Start Module)
    (Body
      (begin Stmt * Body)
      (let ((Var Type Lifted-Expr) *) Body)
      (if Triv Body)
      (if Triv Body Body)
      Ret-Stmt)      
    (Ret-Stmt (return Triv) (return))
    (Stmt
      (let ((Var Type Lifted-Expr) *) Stmt)
      (if Triv Stmt)
      (if Triv Stmt Stmt)
      (begin Stmt * Stmt)
      (print Triv)
      (print Triv Triv)
      (assert Triv)
      (set! Triv Triv)
      (vector-set! Type Triv Triv Triv)
      (do Triv)
      (for (Var Triv Triv Triv) Stmt)
      (while Triv Stmt)
      Ret-Stmt)
    (Lifted-Expr
      (kernel Type (Triv +) (((Var Type) (Triv Type) Integer) +) Expr)
      (make-vector Type Triv)
      Triv)
    (Expr
      (let ((Var Type Lifted-Expr)) Expr)
      (begin Stmt * Expr)
      Triv)
    (Triv
      (if Triv Triv Triv)
      (call Triv Triv *)
      (int->float Triv)
      (length Triv)
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (bool Boolean)
      (var Type Var)
      (vector-ref Type Triv Triv)
      (Binop Triv Triv)
      (Relop Triv Triv)))

  ;; This is really not true, the grammar does change.  Lazy!
  (remove-nested-kernels
    (%inherits Module Decl Stmt Body Lifted-Expr Expr Triv Ret-Stmt)
    (Start Module))

  (returnify-kernels (%inherits Module Decl Body Triv Ret-Stmt)
    (Start Module)
    (Stmt
      (print Triv)
      (print Triv Triv)
      (assert Triv)
      (set! Triv Triv)
      (vector-set! Type Triv Triv Triv)
      (kernel Type (Triv +) (((Var Type) (Triv Type) Integer) +) Stmt)
      (let ((Var Type Lifted-Expr) *) Stmt)
      (if Triv Stmt)
      (if Triv Stmt Stmt)
      (for (Var Triv Triv Triv) Stmt)
      (while Triv Stmt)
      (do Triv)
      (begin Stmt * Stmt)
      Ret-Stmt)
    (Lifted-Expr
      (make-vector Type Triv)
      Triv))

  (make-vector-refs-explicit
    (%inherits Module Decl Body Stmt Ret-Stmt Lifted-Expr)
    (Start Module)
    (Triv
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (var Type Var)
      (int->float Triv)
      (length Triv)
      (addressof Triv)
      (deref Triv)
      (if Triv Triv Triv)
      (call Triv Triv *)
      (c-expr C-Type Var)
      (vector-ref Type Triv Triv)
      (Binop Triv Triv)
      (Relop Triv Triv)))

  (annotate-free-vars (%inherits Module Decl Body Lifted-Expr Triv Ret-Stmt)
    (Start Module)
    (Stmt
      (print Triv)
      (print Triv Triv)
      (assert Triv)
      (set! Triv Triv)
      (vector-set! Type Triv Triv Triv)
      (kernel Type
        (Triv +)
        (((Var Type) (Triv Type) Integer) +)
        (free-vars (Var Type) *)
        Stmt)
      (let ((Var Type Lifted-Expr) *) Stmt)
      (if Triv Stmt)
      (if Triv Stmt Stmt)
      (for (Var Triv Triv Triv) Stmt)
      (while Triv Stmt)
      (do Triv)
      (begin Stmt * Stmt)
      Ret-Stmt))

  (insert-let-regions (%inherits Module Body Lifted-Expr Triv Ret-Stmt)
    (Start Module)
    (Decl
      (extern Var (Type *) -> Type)
      (fn Var (Var *) Type
          (input-regions ((Var *) *))
          (output-regions (Var *))
          Stmt))
    (Stmt
      (print Triv)
      (print Triv Triv)
      (assert Triv)
      (set! Triv Triv)
      (vector-set! Type Triv Triv Triv)
      (kernel Type
        (Triv +)
        (((Var Type) (Triv Type) Integer) +)
        (free-vars (Var Type) *)
        Stmt)
      (let ((Var Type Lifted-Expr) *) Stmt)
      (let-region (Var *) Stmt)
      (if Triv Stmt)
      (if Triv Stmt Stmt)
      (for (Var Triv Triv Triv) Stmt)
      (while Triv Stmt)
      (do Triv)
      (begin Stmt * Stmt)
      Ret-Stmt))

  (infer-regions (%inherits Module Ret-Stmt)
    (Start Module)
    (Decl
      (extern Var (Rho-Type *) -> Rho-Type)
      (fn Var (Var *) Type
          (input-regions ((Var *) *))
          (output-regions (Var *))
          Body))
    (Body
      (begin Stmt * Body)
      (let ((Var Rho-Type Lifted-Expr) *) Body)
      (let-region (Var) Body)
      (if Triv Body)
      (if Triv Body Body)
      Ret-Stmt)
    (Stmt
      (print Triv)
      (print Triv Triv)
      (assert Triv)
      (set! Triv Triv)
      (vector-set! Rho-Type Triv Triv Triv)
      (kernel
        (Triv +)
        (((Var Rho-Type) (Triv Rho-Type) Integer) +)
        (free-vars (Var Rho-Type) *)
        Stmt)
      (let ((Var Rho-Type Lifted-Expr) *) Stmt)
      (let-region (Var) Stmt)
      (if Triv Stmt)
      (if Triv Stmt Stmt)
      (for (Var Triv Triv Triv) Stmt)
      (while Triv Stmt)
      (do Triv)
      (begin Stmt * Stmt)
      Ret-Stmt)
    (Lifted-Expr
      (make-vector Rho-Type Triv)
      Triv)
    (Triv
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (float Float)
      (str String)
      (var Rho-Type Var)
      (int->float Triv)
      (length Triv)
      (addressof Triv)
      (deref Triv)
      (if Triv Triv Triv)
      (call Triv Triv *)
      (c-expr C-Type Var)
      (vector-ref Rho-Type Triv Triv)
      (Binop Triv Triv)
      (Relop Triv Triv))
    (Rho-Type
      harlan-type
      (vec Var Rho-Type)
      (ptr Rho-Type)
      ((Rho-Type *) -> Rho-Type)))

  (uglify-vectors (%inherits Module)
    (Start Module)
    (Decl
      (extern Var (Type *) -> Type)
      (global Var Type Expr)
      (fn Var (Var *) Type Body))
    (Body
      (begin Stmt * Body)
      (let ((Var Type Expr) *) Body)
      (let-region (Var *) Body)
      (if Expr Body)
      (if Expr Body Body)
      Ret-Stmt)
    (Ret-Stmt (return Expr) (return))
    (Stmt
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (kernel (Expr +) (((Var Type) (Expr Type) Integer) +)
        (free-vars (Var Type) *)
        Stmt)
      (let ((Var Type Expr) *) Stmt)
      (let-region (Var *) Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      (begin Stmt +)
      Ret-Stmt)
    (Expr
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (str String)
      (float Float)
      (var Type Var)
      (alloc Expr Expr)
      (region-ref Type Expr Expr)
      (c-expr C-Type Var)
      (if Expr Expr Expr)
      (call Expr Expr *)
      (cast Type Expr)
      (sizeof Type)
      (addressof Expr)
      (deref Expr)
      (vector-ref Type Expr Expr)
      (length Expr)
      (Relop Expr Expr)
      (Binop Expr Expr)))

  (remove-let-regions (%inherits Module Decl Ret-Stmt Expr)
    (Start Module)
    (Body
      (begin Stmt * Body)
      (let ((Var Type Expr) *) Body)
      (if Expr Body)
      (if Expr Body Body)
      Ret-Stmt)
    (Stmt
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (kernel (Expr +) (((Var Type) (Expr Type) Integer) +)
        (free-vars (Var Type) *)
        Stmt)
      (let ((Var Type Expr) *) Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      (begin Stmt +)
      Ret-Stmt))


  (flatten-lets (%inherits Module Decl Ret-Stmt)
    (Start Module)
    (Body
      (begin Stmt * Body)
      (if Expr Body)
      (if Expr Body Body)
      Ret-Stmt)
    (Stmt
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (kernel (Expr +)
       (((Var Type) (Expr Type) Integer) +)
       (free-vars (Var Type) *) Stmt)
      (let Var Type Expr)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      (begin Stmt +)
      Ret-Stmt)
    (Expr
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (str String)
      (float Float)
      (var Type Var)
      (alloc Expr Expr)
      (region-ref Type Expr Expr)
      (c-expr Type Var)
      (if Expr Expr Expr)
      (call Expr Expr *)
      (cast Type Expr)
      (sizeof Type)
      (addressof Expr)
      (deref Expr)
      (vector-ref Type Expr Expr)
      (length Expr)
      (Relop Expr Expr)
      (Binop Expr Expr)))

  (hoist-kernels (%inherits Module Body Ret-Stmt)
    (Start Module)
    (Decl
      (gpu-module Kernel *)
      (fn Var (Var *) ((Type *) -> Type) Body)
      (global Var Type Expr)
      (extern Var (Type *) -> Type))
    (Kernel
      (kernel Var ((Var Type) +) Stmt))
    (Stmt 
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (apply-kernel Var (Expr +) Expr +)
      (let Var Type Expr)
      (begin Stmt * Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      Ret-Stmt)
    (Expr
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (str String)
      (float Float)
      (var Type Var)
      (var C-Type Var)
      (alloc Expr Expr)
      (region-ref Type Expr Expr)
      (c-expr C-Type Var)
      (if Expr Expr Expr)
      (field (var C-Type Var) Var)
      (deref Expr)
      (call Expr Expr *)
      (cast Type Expr)
      (sizeof Type)
      (addressof Expr)
      (vector-ref Type Expr Expr)
      (Relop Expr Expr)
      (Binop Expr Expr)))

  (generate-kernel-calls
    (%inherits Module Kernel Decl Expr Body Ret-Stmt)
    (Start Module)
    (Stmt
      (print Expr)
      (print Expr Expr)
      (assert Expr)
      (set! Expr Expr)
      (let Var C-Type Expr)
      (begin Stmt * Stmt)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      Ret-Stmt))

  (compile-module
    (%inherits Kernel Body Ret-Stmt)
    (Start Module)
    (Module (Decl *))
    (Decl
      (include String)
      (gpu-module Kernel *)
      (func Type Var ((Var Type) *) Body)
      (global Var Type Expr)
      (extern Type Var (Type *)))
    (Stmt
      (print Expr)
      (print Expr Expr)
      (set! Expr Expr)
      (if Expr Stmt)
      (if Expr Stmt Stmt)
      (let Var C-Type Expr)
      (begin Stmt * Stmt)
      (for (Var Expr Expr Expr) Stmt)
      (while Expr Stmt)
      (do Expr)
      Ret-Stmt)
    (Expr
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (str String)
      (float Float)
      (var Var)
      (alloc Expr Expr)
      (region-ref Type Expr Expr)
      (c-expr Var)
      (deref Expr)
      (field Var +)
      (field Var + Type)
      (call Expr Expr *)
      (assert Expr)
      (cast Type Expr)
      (if Expr Expr Expr)
      (sizeof Type)
      (addressof Expr)
      (vector-ref Expr Expr)
      (Relop Expr Expr)
      (Binop Expr Expr)))

  (convert-types (%inherits Module Stmt Body Ret-Stmt)
    (Start Module)
    (Decl
      (include String)
      (gpu-module Kernel *)
      (func C-Type Var ((Var C-Type) *) Body)
      (global C-Type Var Expr)
      (extern C-Type Var (C-Type *))) 
    (Kernel
      (kernel Var ((Var C-Type) +) Stmt))
    (Expr
      (bool Boolean)
      (char Char)
      (int Integer)
      (u64 Number)
      (str String)
      (float Float)
      (var Var)
      (alloc Expr Expr)
      (region-ref Type Expr Expr)
      (c-expr Var)
      (deref Expr)
      (field Var +)
      (field Var + C-Type)
      (call Expr Expr *)
      (assert Expr)
      (if Expr Expr Expr)
      (cast C-Type Expr)
      (sizeof C-Type)
      (addressof Expr)
      (vector-ref Expr Expr)
      (Relop Expr Expr)
      (Binop Expr Expr)))

  )
)