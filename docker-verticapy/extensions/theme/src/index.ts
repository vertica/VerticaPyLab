import {
  ILabShell,
  JupyterFrontEnd,
  JupyterFrontEndPlugin
} from '@jupyterlab/application';
import { ICommandPalette, MainAreaWidget } from '@jupyterlab/apputils';
import { ILauncher, LauncherModel } from '@jupyterlab/launcher';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { ITranslator } from '@jupyterlab/translation';
import { launcherIcon } from '@jupyterlab/ui-components';

import { toArray } from '@lumino/algorithm';
import { Widget } from '@lumino/widgets';


import { Launcher, verticaIcon } from './launcher';
import '../style/index.css';

const VERTICA_THEME_NAMESPACE = 'theme:plugin';
/**
 * The command IDs used by the launcher plugin.
 */
const CommandIDs = {
  create: 'launcher:create'
};

/**
 * Initialization data for the theme extension.
 */
const plugin: JupyterFrontEndPlugin<ILauncher> = {
  id: VERTICA_THEME_NAMESPACE,
  autoStart: true,
  requires: [ITranslator, ILabShell, IMainMenu],
  optional: [ICommandPalette],
  provides: ILauncher,
  activate: (
    app: JupyterFrontEnd,
    translator: ITranslator,
    labShell: ILabShell,
    mainMenu: IMainMenu,
    palette: ICommandPalette | null
    ): ILauncher => {
    console.log('JupyterLab extension theme is activated!');

    // Find the MainLogo widget in the shell and replace it with the Vertica Logo
    const widgets = app.shell.widgets('top');
    let widget = widgets.next();

    while (widget !== undefined) {
      if (widget.id === 'jp-MainLogo') {
        verticaIcon.element({
          container: widget.node,
          justify: 'center',
          margin: '2px 5px 2px 5px',
          height: 'auto',
          width: '20px'
        });
        break;
      }

      widget = widgets.next();
    }

    // Use custom Vertica launcher
    const { commands } = app;
    const trans = translator.load('jupyterlab');
    const model = new LauncherModel();

    commands.addCommand(CommandIDs.create, {
      label: trans.__('New Launcher'),
      execute: (args: any) => {
        const cwd = args['cwd'] ? String(args['cwd']) : '';
        const id = `launcher-${Private.id++}`;
        const callback = (item: Widget): void => {
          labShell.add(item, 'main', { ref: id });
        };

        const launcher = new Launcher({
          model,
          cwd,
          callback,
          commands,
          translator
        });

        launcher.model = model;
        launcher.title.icon = launcherIcon;
        launcher.title.label = trans.__('Launcher');

        const main = new MainAreaWidget({ content: launcher });

        // If there are any other widgets open, remove the launcher close icon.
        main.title.closable = !!toArray(labShell.widgets('main')).length;
        main.id = id;

        labShell.add(main, 'main', { activate: args['activate'] as boolean });

        labShell.layoutModified.connect(() => {
          // If there is only a launcher open, remove the close icon.
          main.title.closable = toArray(labShell.widgets('main')).length > 1;
        }, main);

        return main;
      }
    });

    if (palette) {
      palette.addItem({
        command: CommandIDs.create,
        category: trans.__('Launcher')
      });
    }

    return model;

  }
};

/**
 * The namespace for module private data.
 */
 namespace Private {
  /**
   * The incrementing id used for launcher widgets.
   */
  // eslint-disable-next-line
  export let id = 0;
}

export default plugin;
