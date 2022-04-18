import {
  ILayoutRestorer,
  JupyterFrontEnd,
  JupyterFrontEndPlugin,
} from '@jupyterlab/application';
import {
  MainAreaWidget,
  WidgetTracker,
  ICommandPalette
} from '@jupyterlab/apputils';
import { terminalIcon } from '@jupyterlab/ui-components';
import { ILauncher } from '@jupyterlab/launcher';
import { ISettingRegistry } from '@jupyterlab/settingregistry';
// Name-only import so as to not trigger inclusion in main bundle
import * as WidgetModuleType from '@jupyterlab/terminal/lib/widget';
import { ITerminalTracker, 
         ITerminal 
} from '@jupyterlab/terminal';

/**
 * The command IDs used by the terminal plugin.
 */
namespace CommandIDs {
  export const createNew = 'bash:create-new';

  export const open = 'bash:open';

  export const refresh = 'bash:refresh';

  export const increaseFont = 'bash:increase-font';

  export const decreaseFont = 'bash:decrease-font';

  export const setTheme = 'bash:set-theme';
}

function activate(
  app: JupyterFrontEnd,
  settingRegistry: ISettingRegistry,
  launcher: ILauncher,
  palette: ICommandPalette,
  restorer: ILayoutRestorer | null
): ITerminalTracker{
  console.log('JupyterLab extension verticatools is activated!');
  const { serviceManager } = app;
  const namespace = 'bash';
  const tracker = new WidgetTracker<MainAreaWidget<ITerminal.ITerminal>>({
    namespace
  });
      
  // Bail if there are no terminals available.
  if (!serviceManager.terminals.isAvailable()) {
    console.warn(
      'Disabling terminals plugin because they are not available on the server'
    );
    return tracker;
  }
      
 //   Handle state restoration.
  if (restorer) {
    void restorer.restore(tracker, {
      command: CommandIDs.createNew,
      args: widget => ({ name: widget.content.session.name }),
      name: widget => widget.content.session.name
    });
  }
      

      
  // The cached terminal options from the setting editor.
  let command = 'clear; vertica-tools; exit 0;'
  const options: Partial<ITerminal.IOptions> = { initialCommand: command };
  addCommands(app, tracker, options);
      
  // Add a launcher item if the launcher is available.
  if (launcher) {
    launcher.add({
      command: CommandIDs.createNew,
      category: 'Other',
      rank: 0
    });
  }

  /* 
  palette.addItem({
    command: CommandIDs.createNew,
    args: { isPalette: true },
    category: 'Vertica'
  });
  */
  return tracker;
}


export function addCommands(
  app: JupyterFrontEnd,
  tracker: WidgetTracker<MainAreaWidget<ITerminal.ITerminal>>,
  options: Partial<ITerminal.IOptions>
) {
//   const { commands, serviceManager } = app;
  const { commands, serviceManager } = app
  // Add an application command
  /**
  * addCommand https://jupyterlab.github.io/lumino/commands/classes/commandregistry.html#addcommand
  * addCommand：
  * id: string
  * The unique id of the command.
  *
  * options: ICommandOptions
  * The options for the command.
  
  * ICommandOptions https://jupyterlab.github.io/lumino/commands/interfaces/commandregistry.icommandoptions.html
  * ICommandOptions：
  * label: string
  * The label for the command.
  *
  * caption: string
  * The caption for the command.
  *
  * icon: string | CommandFunc<string>
  * Use iconClass instead.
  * iconClass: string | CommandFunc<string>
  * The icon class for the command.
  
  * exec: CommandFunc<any | Promise<any>>
  * The function to invoke when the command is executed.
  */
  commands.addCommand(CommandIDs.createNew, {
    label: args => (args['isPalette'] ? 'Verticatools' : 'Verticatools'),
    caption: 'Open a vsql or admintools session',
    icon: args => (args['isPalette'] ? undefined : terminalIcon),
    execute: async args => {
      // wait for the widget to lazy load
      let Terminal: typeof WidgetModuleType.Terminal;
      try {
        //Terminal
        Terminal = (await Private.ensureWidget()).Terminal;
      } catch (err) {
        Private.showErrorMessage(err);
        return;
      }
      const name = args['name'] as string;

      const session = await (name
        ? serviceManager.terminals.connectTo({ model: { name } })
        : serviceManager.terminals.startNew());

      const term = new Terminal(session, options);

      term.title.icon = terminalIcon;
      term.title.label = '...';

      const main = new MainAreaWidget({ content: term });
      app.shell.add(main);
      void tracker.add(main);
      app.shell.activateById(main.id);
      return main;
      
    }
  });

}

/**
 * Initialization data for the Verticatools extension.
 */
const extension: JupyterFrontEndPlugin <ITerminalTracker>  = {
  id: 'verticatools:plugin',
  autoStart: true,
  provides: ITerminalTracker,
  requires: [ISettingRegistry, ILauncher, ICommandPalette],
  optional: [ILayoutRestorer],
  activate: activate
};


namespace Private {
  /**
   * A Promise for the initial load of the terminal widget.
   */
  export let widgetReady: Promise<typeof WidgetModuleType>;

  /**
   * Lazy-load the widget (and xterm library and addons)
   */
  export function ensureWidget(): Promise<typeof WidgetModuleType> {
    if (widgetReady) {
      return widgetReady;
    }

    widgetReady = import('@jupyterlab/terminal/lib/widget');

    return widgetReady;
  }

  /**
   *  Utility function for consistent error reporting
   */
  export function showErrorMessage(error: Error): void {
    console.error(`Failed to configure ${extension.id}: ${error.message}`);
  }
}

export default extension;