# Godot's text-editor (syntax) theme, generated from the active Stylix palette
# so the code editor matches the rest of the system. This mirrors how gitea /
# tuigreet / blender are themed straight from `config.lib.stylix.colors`
# (Stylix has no godot target of its own).
#
# `.tet` files are Godot's drop-in text-editor themes: dropping this file makes
# a theme named "Stylix" appear under
#   Editor > Editor Settings > Text Editor > Theme.
# Select it there once. Format reference: github.com/catppuccin/godot
#
# Note: this only themes the code editor. Godot's *interface* (UI chrome) colors
# aren't a drop-in file — set base/accent under Interface > Theme manually if you
# want the chrome to match too.
{
  config,
  lib,
  ...
}:
lib.mkIf config.stylix.enable (let
  c = config.lib.stylix.colors;
in {
  xdg.configFile."godot/text_editor_themes/Stylix.tet".text = ''
    [color_theme]

    symbol_color="${c.base05}ff"
    keyword_color="${c.base0E}ff"
    control_flow_keyword_color="${c.base0E}ff"
    base_type_color="${c.base0A}ff"
    engine_type_color="${c.base0A}ff"
    user_type_color="${c.base0A}ff"
    comment_color="${c.base03}ff"
    string_color="${c.base0B}ff"
    background_color="${c.base00}ff"
    completion_background_color="${c.base01}ff"
    completion_selected_color="${c.base02}ff"
    completion_existing_color="${c.base0D}21"
    completion_scroll_color="${c.base02}ff"
    completion_scroll_hovered_color="${c.base03}ff"
    completion_font_color="${c.base05}ff"
    text_color="${c.base05}ff"
    line_number_color="${c.base04}ff"
    safe_line_number_color="${c.base0B}ff"
    caret_color="${c.base05}ff"
    caret_background_color="000000ff"
    text_selected_color="${c.base05}ff"
    selection_color="${c.base04}ff"
    brace_mismatch_color="${c.base08}ff"
    current_line_color="${c.base05}10"
    line_length_guideline_color="${c.base02}ff"
    word_highlighted_color="${c.base04}ff"
    number_color="${c.base09}ff"
    function_color="${c.base0D}ff"
    member_variable_color="${c.base07}ff"
    mark_color="${c.base08}38"
    bookmark_color="${c.base0D}ff"
    breakpoint_color="${c.base08}ff"
    executing_line_color="${c.base0A}ff"
    code_folding_color="${c.base04}ff"
    search_result_color="${c.base04}ff"
    search_result_border_color="00000000"
    gdscript/function_definition_color="${c.base0D}ff"
    gdscript/global_function_color="${c.base08}ff"
    gdscript/node_path_color="${c.base0C}ff"
    gdscript/node_reference_color="${c.base0C}ff"
    gdscript/annotation_color="${c.base09}ff"
    gdscript/string_name_color="${c.base05}ff"
  '';
})
