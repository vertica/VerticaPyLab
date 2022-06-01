import { ScriptEditorWidgetFactory, ScriptEditor } from '@elyra/script-editor';

import {
  JupyterFrontEnd,
  JupyterFrontEndPlugin,
  ILayoutRestorer
} from '@jupyterlab/application';
import { WidgetTracker, ICommandPalette } from '@jupyterlab/apputils';
import { CodeEditor, IEditorServices } from '@jupyterlab/codeeditor';
import {
  IDocumentWidget,
  DocumentRegistry,
  DocumentWidget
} from '@jupyterlab/docregistry';
import { IFileBrowserFactory } from '@jupyterlab/filebrowser';
import { FileEditor, IEditorTracker } from '@jupyterlab/fileeditor';
import { ILauncher } from '@jupyterlab/launcher';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { ISettingRegistry } from '@jupyterlab/settingregistry';

import { JSONObject } from '@lumino/coreutils';

import { SqlEditor, sqlIcon } from './SqlEditor';

const SQL_FACTORY = 'Sql Editor';
const SQL = 'sql';
const SQL_EDITOR_NAMESPACE = 'sql-editor:plugin';

const commandIDs = {
  createNewSqlEditor: 'sql-editor:create-new-sql-editor',
  openDocManager: 'docmanager:open',
  newDocManager: 'docmanager:new-untitled'
};

/**
 * Initialization data for the sql-editor extension.
 */
const plugin: JupyterFrontEndPlugin<void> = {
  id: SQL_EDITOR_NAMESPACE,
  autoStart: true,
  requires: [
    IEditorServices,
    IEditorTracker,
    ICommandPalette,
    ISettingRegistry,
    IFileBrowserFactory
  ],
  optional: [ILayoutRestorer, IMainMenu, ILauncher],
  activate: (
    app: JupyterFrontEnd,
    editorServices: IEditorServices,
    editorTracker: IEditorTracker,
    palette: ICommandPalette,
    settingRegistry: ISettingRegistry,
    browserFactory: IFileBrowserFactory,
    restorer: ILayoutRestorer | null,
    menu: IMainMenu | null,
    launcher: ILauncher | null
    ) => {
    console.log('JupyterLab extension sql-editor is activated!');

    const factory = new ScriptEditorWidgetFactory({
      editorServices,
      factoryOptions: {
        name: SQL_FACTORY,
        fileTypes: [SQL],
        defaultFor: [SQL]
      },
      instanceCreator: (
        options: DocumentWidget.IOptions<
          FileEditor,
          DocumentRegistry.ICodeModel
        >
      ): ScriptEditor => new SqlEditor(options)
    });

    app.docRegistry.addFileType({
      name: SQL,
      displayName: 'Sql File',
      extensions: ['.sql'],
      pattern: '.*\\.sql$',
      mimeTypes: ['text/x-sql'],
      icon: sqlIcon
    });


    const { restored } = app;

    /**
     * Track SqlEditor widget on page refresh
     */
    const tracker = new WidgetTracker<ScriptEditor>({
      namespace: SQL_EDITOR_NAMESPACE
    });

    let config: CodeEditor.IConfig = { ...CodeEditor.defaultConfig };

    if (restorer) {
      // Handle state restoration
      void restorer.restore(tracker, {
        command: commandIDs.openDocManager,
        args: widget => ({
          path: widget.context.path,
          factory: SQL_FACTORY
        }),
        name: widget => widget.context.path
      });
    }

    /**
     * Update the setting values. Adapted from fileeditor-extension.
     */
     const updateSettings = (settings: ISettingRegistry.ISettings): void => {
      config = {
        ...CodeEditor.defaultConfig,
        ...(settings.get('editorConfig').composite as JSONObject)
      };

      // Trigger a refresh of the rendered commands
      app.commands.notifyCommandChanged();
    };

    /**
     * Update the settings of the current tracker instances. Adapted from fileeditor-extension.
     */
    const updateTracker = (): void => {
      tracker.forEach(widget => {
        updateWidget(widget);
      });
    };


    /**
     * Update the settings of a widget. Adapted from fileeditor-extension.
     */
     const updateWidget = (widget: ScriptEditor): void => {
      if (!editorTracker.has(widget)) {
        (editorTracker as WidgetTracker<IDocumentWidget<FileEditor>>).add(
          widget
        );
      }

      const editor = widget.content.editor;
      Object.keys(config).forEach((keyStr: string) => {
        const key = keyStr as keyof CodeEditor.IConfig;
        editor.setOption(key, config[key]);
      });
    };


    // Fetch the initial state of the settings. Adapted from fileeditor-extension.
    Promise.all([
      settingRegistry.load('@jupyterlab/fileeditor-extension:plugin'),
      restored
    ])
      .then(([settings]) => {
        updateSettings(settings);
        updateTracker();
        settings.changed.connect(() => {
          updateSettings(settings);
          updateTracker();
        });
      })
      .catch((reason: Error) => {
        console.error(reason.message);
        updateTracker();
      });

    app.docRegistry.addWidgetFactory(factory);

    factory.widgetCreated.connect((sender, widget) => {
      void tracker.add(widget);

      // Notify the widget tracker if restore data needs to update
      widget.context.pathChanged.connect(() => {
        void tracker.save(widget);
      });
      updateWidget(widget);
    });


    // Handle the settings of new widgets. Adapted from fileeditor-extension.
    tracker.widgetAdded.connect((sender, widget) => {
      updateWidget(widget);
    });

    /**
     * Create new sql editor from launcher and file menu
     */

    // Add a sql launcher
    if (launcher) {
      launcher.add({
        command: commandIDs.createNewSqlEditor,
        category: 'Vertica',
        rank: 2
      });
    }

    if (menu) {
      // Add new sql editor creation to the file menu
      menu.fileMenu.newMenu.addGroup(
        [{ command: commandIDs.createNewSqlEditor, args: { isMenu: true } }],
        92
      );
    }


    // Function to create a new untitled sql file, given the current working directory
    const createNew = (cwd: string): Promise<any> => {
      return app.commands
        .execute(commandIDs.newDocManager, {
          path: cwd,
          type: 'file',
          ext: '.sql'
        })
        .then(model => {
          return app.commands.execute(commandIDs.openDocManager, {
            path: model.path,
            factory: SQL_FACTORY
          });
        });
    };

    // Add a command to create new sql editor
    app.commands.addCommand(commandIDs.createNewSqlEditor, {
      label: args =>
        args['isPalette'] ? 'New Sql Editor' : 'Sql Editor',
      caption: 'Create a new Sql Editor',
      icon: args => (args['isPalette'] ? undefined : sqlIcon),
      execute: args => {
        const cwd = args['cwd'] || browserFactory.defaultBrowser.model.path;
        return createNew(cwd as string);
      }
    });


    palette.addItem({
      command: commandIDs.createNewSqlEditor,
      args: { isPalette: true },
      category: 'Vertica'
    });


  }
};

export default plugin;
