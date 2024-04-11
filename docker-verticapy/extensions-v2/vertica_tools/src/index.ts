import {
  ILabShell,
  JupyterFrontEnd,
  JupyterFrontEndPlugin
} from '@jupyterlab/application';
import { ILauncher, LauncherModel as JupyterLauncherModel } from '@jupyterlab/launcher';

import { ICommandPalette, MainAreaWidget } from '@jupyterlab/apputils';
import { IMainMenu } from '@jupyterlab/mainmenu';
import { ITranslator } from '@jupyterlab/translation';
import { launcherIcon, addIcon } from '@jupyterlab/ui-components';
import { toArray } from '@lumino/algorithm';
import { Widget } from '@lumino/widgets';

import { Launcher, VERTICAPY_UI, VERTICAPY_LESSONS, VERTICA } from './launcher';
import { verticapyIcon, queryIcon, course1Icon, grafanaIcon, rocketIcon } from './icon';

namespace CommandIDs {
  export const createNew = 'launcher:create';
  export const openConnect = "launcher:connect";
  export const openQprof = "launcher:qprof";
  export const openCourseDSE = 'launcher:open-dse';
  export const openHelp = 'launcher:open-help';
  export const openGrafanaExplorer = 'launcher:explorer';
  export const openVerticaPerformanceDashboard = 'launcher:perf'
}

/**
 * constants used by grafana commands
 */

namespace Grafana {
  // 'PORT' will be overridden by the actual port used by the grafana container
  export const port = "3000";

  export const explorerPathName = "explore";

  export const perfDashboardPathName = "d/vertica-perf/vertica-performance-dashboard";
}

const extension: JupyterFrontEndPlugin<ILauncher> = {
  id: 'vertica_launcher:plugin',
  description: 'A custom launcher for vertica extensions.',
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
    const { commands } = app;
    const command = CommandIDs.createNew;

    const trans = translator.load('jupyterlab');
    const model = new JupyterLauncherModel();

    commands.addCommand(command, {
      label: trans.__('New Launcher'),
      icon: addIcon,
      execute: async args => {
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

    commands.addCommand(CommandIDs.openConnect, {
      label: 'Connect',
      icon: verticapyIcon,
      execute: (args: any) => {
        window.open('/voila/render/ui/conn.ipynb?', '_blank');
      }
    });

    commands.addCommand(CommandIDs.openQprof, {
      label: 'Query Profiler',
      icon: queryIcon,
      execute: (args: any) => {
        window.open('/voila/render/ui/qprof_main.ipynb?', '_blank');
      }
    });

    commands.addCommand(CommandIDs.openCourseDSE, {
      label: 'Data Science Essentials',
      icon: course1Icon,
      execute: (args: any) => {
        window.open('/voila/render/demos/enablement/Data%20Science%20Essentials/Data_Science_Essentials.ipynb?', '_blank');
      }
    });

    commands.addCommand(CommandIDs.openHelp, {
      label: 'Documentation',
      icon: verticapyIcon,
      execute: (args: any) => {
        window.open('https://www.vertica.com/python/', '_blank');
      }
    });

    let grafanaUrl = new URL(window.location.href);
    grafanaUrl.port = Grafana.port;
    // Create grafana explorer and vertica performance dashboard urls
    let explorerUrl = new URL(grafanaUrl.href);
    let perfDashboardUrl = new URL(grafanaUrl.href);
    explorerUrl.pathname = Grafana.explorerPathName;
    perfDashboardUrl.pathname = Grafana.perfDashboardPathName;
    
    commands.addCommand(CommandIDs.openGrafanaExplorer, {
      label: 'Grafana',
      caption: 'Open Grafana',
      icon: grafanaIcon,
      execute: (args: any) => {
        window.open(explorerUrl.href, '_blank');
      }
    });

    commands.addCommand(CommandIDs.openVerticaPerformanceDashboard, {
      label: 'Performance',
      caption: 'Open Performance Dashboard',
      icon: rocketIcon,
      execute: (args: any) => {
        window.open(perfDashboardUrl.href, '_blank');
      }
    });

    // Add the command to the palette
    if (palette) {
      palette.addItem({
        command,
        category: trans.__('Launcher')
      });
    }

    model.add({
      command: CommandIDs.openConnect,
      category: VERTICAPY_UI,
      rank: 1
    });

    model.add({
      command: CommandIDs.openQprof,
      category: VERTICAPY_UI,
      rank: 2
    });

    model.add({
      command: CommandIDs.openCourseDSE,
      category: VERTICAPY_LESSONS,
      rank: 1
    });

    model.add({
      command: CommandIDs.openHelp,
      category: VERTICAPY_LESSONS,
      rank: 2
    });

    model.add({
      command: CommandIDs.openGrafanaExplorer,
      category: VERTICA,
      rank: 1
    });

    model.add({
      command: CommandIDs.openVerticaPerformanceDashboard,
      category: VERTICA,
      rank: 2
    });

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

export default extension;
