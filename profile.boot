;; https://github.com/boot-clj/boot/wiki/Cider-REPL
;; https://github.com/clojure-emacs/cider-nrepl#via-boot

#_(merge-env!
   :mirrors {#"clojars" {:name "clojars mirror"
                         :url  "https://clojars-mirror.tcrawley.org/repo/"}})

(def v-tools-nrepl "0.2.12")
(def v-cider-nrepl "0.15.0-SNAPSHOT")
(def v-refactor-nrepl "2.3.0-SNAPSHOT")

(deftask cider "CIDER profile"
  []
  (require 'boot.repl)
  (swap! @(resolve 'boot.repl/*default-dependencies*)
         concat `[[org.clojure/tools.nrepl ~v-tools-nrepl]
                  [cider/cider-nrepl ~v-cider-nrepl]
                  [~'refactor-nrepl ~v-refactor-nrepl]
                  [acyclic/squiggly-clojure "0.1.8"]])
  (swap! @(resolve 'boot.repl/*default-middleware*)
         concat '[cider.nrepl/cider-middleware
                  refactor-nrepl.middleware/wrap-refactor])
  identity)
