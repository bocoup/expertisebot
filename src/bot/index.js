import {createSlackBot, createCommand, createConversation, createArgsAdjuster} from 'chatter';
import {RtmClient, WebClient, MemoryDataStore} from '@slack/client';
import {jobs, jobCommand} from './jobs';
import mixinBotHelpers from './helpers';
import config from '../../config';

// Sub-commands.
import skillCommand from './commands/skill';
import {userCommand, meCommand} from './commands/user';
import listCommand from './commands/list';
import scalesCommand from './commands/scales';
import statsCommand from './commands/stats';
import updateCommand from './commands/update';
import adminCommand from './commands/admin';
import versionCommand from './commands/version';
import bocoupImportCommand from './commands/bocoup-import';

export default function createBot(token) {

  const bot = createSlackBot({
    name: 'Skills Bot',
    verbose: true,
    getSlack() {
      return {
        rtmClient: new RtmClient(token, {
          dataStore: new MemoryDataStore(),
          autoReconnect: true,
          logLevel: 'error',
        }),
        webClient: new WebClient(token),
      };
    },
    createMessageHandler(id, {channel}) {
      // Get name and aliases for bot, based on the actual bot name, and
      // whether or not the bot is in a public channel or DM.
      const {name, aliases} = this.getBotNameAndAliases(channel.is_im);
      // Helper method to format the given command name.
      const getCommand = cmd => name ? `${name} ${cmd}` : cmd;
      // Dev-only commands.
      const devCommands = [adminCommand];
      // Bocoup team-only commands.
      const bocoupCommands = [];
      if (bot.slack.rtmClient.activeTeamId === config.bocoupTeamId) {
        bocoupCommands.push(bocoupImportCommand);
      }

      const skillsCommand = createCommand({
        isParent: true,
        name,
        aliases,
        description: 'Show your skills.',
      }, [
        listCommand,
        skillCommand,
        userCommand,
        meCommand,
        updateCommand,
        statsCommand,
        scalesCommand,
        versionCommand,
        jobCommand,
        ...bocoupCommands,
        ...(config.isProduction ? [] : devCommands),
      ]);

      return createConversation([
        createArgsAdjuster(
          {
            // Inject token and getCommand helper function into all commands'
            // meta object (2nd argument).
            adjustArgs(message, meta) {
              return [message, Object.assign(meta, {
                token,
                getCommand,
              })];
            },
          },
          skillsCommand
        ),
      ]);
    },
  });

  mixinBotHelpers(bot);

  if (config.runJobs) {
    jobs.start({bot, token});
  }

  return bot;

}
