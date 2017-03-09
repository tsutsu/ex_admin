defmodule ExAdmin.ActiveAdmin.LayoutView do
  @moduledoc false
  require Logger
  import ExAdmin.ViewHelpers
  import ExAdmin.Authentication
  import Kernel, except: [div: 2]
  import Xain, except: [tag: 1, tag: 2]
  alias ExAdmin.Utils

  file_path = __ENV__.file
  |> Path.dirname
  |> String.split("/views")
  |> hd
  |> Path.join("templates")
  |> Path.join("themes")

  use Phoenix.View, root: file_path
  # use Phoenix.View, root: "web/templates"

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML

  #import ExAuth
  import ExAdmin.ViewHelpers


  def any_actions?([]), do: false
  def any_actions?(nil), do: false
  def any_actions?([{_, nil} | _]), do: false
  def any_actions?(_), do: true

  def build_menu_icon(_, opts) when opts in [nil, []], do: opts
  def build_menu_icon(action, [{name, opts} | tail] = opts_arg) do
    icon = case action do
      :new -> "fa fa-plus-square"
      :edit -> "fa fa-edit"
      :delete -> "fa fa-minus-square"
      _ -> nil
    end
    if icon do
      [{"<i class='fa #{icon}'></i><span>#{name}</span>", opts} | tail]
    else
      opts_arg
    end
  end

  defp do_scopes(conn, scopes, scope_counts, current_scope) do
    for {name, _opts} <- scopes do
      count = scope_counts[name]
      selected = if "#{name}" == "#{current_scope}", do: "active", else: ""

      li class: selected do
        a href: Utils.admin_resource_path(conn, :index, [[scope: name]]) do
          i ".nav-label.label.label-success" do
            String.at("#{name}", 0)
            |> String.upcase
            |> text
          end
          span do
            text Utils.humanize(name) <> " "
            span ".badge.badge-xs.bg-blue #{count}", style: "margin-top: -2px"
          end
        end
      end
    end
  end

  def build_scopes(_conn, []), do: ""
  def build_scopes(_conn, nil), do: ""
  def build_scopes(conn, scope_counts) do
    defn = conn.assigns.defn
    scopes = defn.scopes
    markup safe: true do
      current_scope = ExAdmin.Query.get_scope scopes, conn.params["scope"]
      # li ".header SCOPES"
      if Application.get_env(:ex_admin_runtime, :nest_scopes, false) do
        li ".treeview" do
          a href: "#" do
            i ".fa.fa-filter"
            span "Scopes"
            i ".fa.fa-angle-left.pull-right"
          end
          ul ".treeview-menu" do
            do_scopes(conn, scopes, scope_counts, current_scope)
          end
        end
      else
        li ".header SCOPES"
        do_scopes(conn, scopes, scope_counts, current_scope)
      end
    end
  end
  def flashes(conn) do
    markup safe: true do
      messages = Enum.reduce [:notice, :error], [], fn(which, acc) ->
        acc ++ get_flash(conn, which)
      end
      if messages != [] do
        Enum.map messages, fn({which, message}) ->
          flash message, which
        end
      end
    end
  end
  def flash(message, :notice) do
    div ".alert.alert-success.alert-dismissable" do
      Xain.button ".close x", "data-dismiss": :alert, "aria-hidden": true
      text message
    end
  end
  def flash(message, :error) do
    div ".alert.alert-error.alert-dismissable" do
      Xain.button ".close x", "data-dismiss": :alert, "aria-hidden": true
      text message
    end
  end
end
