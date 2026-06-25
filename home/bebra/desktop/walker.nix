{ inputs, ... }:

{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  # --- Walker ---
  programs.walker = {
    enable = true;
    runAsService = true;
    config = {
      theme = "matugen";
    };
    themes.matugen = {
      style = ''
        @import url("../../../gtk-4.0/colors.css");
        @define-color theme_fg_color @window_fg_color;
      '';
    };
    themes.screenshot_menu = {
      style = ''
        @import url("../../../gtk-4.0/colors.css");

        .box-wrapper {
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
          background: rgba(30, 30, 46, 0.9);
          border-radius: 16px;
          border: 1px solid rgba(255, 255, 255, 0.1);
          padding: 8px;
          margin-bottom: 40px;
        }


        .item-box {
          border-radius: 12px;
          padding: 12px 20px;
          margin: 0 6px;
          background: rgba(45, 45, 68, 0.6);
        }

        child:selected .item-box,
        row:selected .item-box {
          background: rgb(137, 180, 250);
          color: #1e1e2e;
        }

        .item-text {
          font-weight: bold;
          font-size: 14px;
        }
      '';

      layouts = {
        "layout" = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <interface>
            <requires lib="gtk" version="4.0"></requires>
            <object class="GtkWindow" id="Window">
              <style>
                <class name="window"></class>
              </style>
              <property name="resizable">false</property>
              <property name="title">Screenshot Menu</property>
              <child>
                <object class="GtkBox" id="BoxWrapper">
                  <style>
                    <class name="box-wrapper"></class>
                  </style>
                  <property name="overflow">hidden</property>
                  <property name="orientation">horizontal</property>
                  <property name="valign">center</property>
                  <property name="halign">center</property>
                  <property name="width-request">600</property>
                  <property name="height-request">80</property>
                  <child>
                    <object class="GtkBox" id="Box">
                      <style>
                        <class name="box"></class>
                      </style>
                      <property name="orientation">horizontal</property>
                      <property name="hexpand-set">true</property>
                      <property name="hexpand">true</property>
                      <child>
                        <object class="GtkScrolledWindow" id="Scroll">
                          <style>
                            <class name="scroll"></class>
                          </style>
                          <property name="can_focus">false</property>
                          <property name="hexpand">true</property>
                          <property name="vexpand">true</property>
                          <property name="hscrollbar-policy">never</property>
                          <property name="vscrollbar-policy">never</property>
                          <child>
                            <object class="GtkGridView" id="List">
                              <style>
                                <class name="list"></class>
                              </style>
                              <property name="max_columns">4</property>
                              <property name="min_columns">4</property>
                              <property name="can_focus">false</property>
                            </object>
                          </child>
                        </object>
                      </child>
                    </object>
                  </child>
                </object>
              </child>
            </object>
          </interface>
        '';
      };
    };
  };
}
