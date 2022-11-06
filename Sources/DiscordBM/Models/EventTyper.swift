
public protocol EventTyper {
    associatedtype Wrapped
}

public struct TypedGatewayEvent<T: EventTyper> {
    @usableFromInline
    var event: Gateway.Event
    
    public var data: T.Wrapped {
        self.unwrapInnerData(as: T.Wrapped.self)
    }
    
    @inlinable
    func unwrapInnerData<T>(as: T.Type) -> T {
        switch event.data {
        case .none, .resumed:
            fatalError("No data to unwrap")
        case .heartbeat(let lastSequenceNumber):
            return lastSequenceNumber as! T
        case .identify(let identify):
            return identify as! T
        case .hello(let hello):
            return hello as! T
        case .ready(let ready):
            return ready as! T
        case .resume(let resume):
            return resume as! T
        case .invalidSession(let canResume):
            return canResume as! T
        case .channelCreate(let discordChannel):
            return discordChannel as! T
        case .channelUpdate(let discordChannel):
            return discordChannel as! T
        case .channelDelete(let discordChannel):
            return discordChannel as! T
        case .channelPinsUpdate(let channelPinsUpdate):
            return channelPinsUpdate as! T
        case .threadCreate(let threadCreate):
            return threadCreate as! T
        case .threadUpdate(let discordChannel):
            return discordChannel as! T
        case .threadDelete(let threadDelete):
            return threadDelete as! T
        case .threadSyncList(let threadListSync):
            return threadListSync as! T
        case .threadMemberUpdate(let threadMemberUpdate):
            return threadMemberUpdate as! T
        case .threadMembersUpdate(let threadMembersUpdate):
            return threadMembersUpdate as! T
        case .guildCreate(let guild):
            return guild as! T
        case .guildUpdate(let guild):
            return guild as! T
        case .guildDelete(let unavailableGuild):
            return unavailableGuild as! T
        case .guildBanAdd(let guildBan):
            return guildBan as! T
        case .guildBanRemove(let guildBan):
            return guildBan as! T
        case .guildEmojisUpdate(let guildEmojisUpdate):
            return guildEmojisUpdate as! T
        case .guildStickersUpdate(let guildStickersUpdate):
            return guildStickersUpdate as! T
        case .guildIntegrationsUpdate(let guildIntegrationsUpdate):
            return guildIntegrationsUpdate as! T
        case .guildMemberAdd(let guildMemberAdd):
            return guildMemberAdd as! T
        case .guildMemberRemove(let guildMemberRemove):
            return guildMemberRemove as! T
        case .guildMemberUpdate(let guildMemberUpdate):
            return guildMemberUpdate as! T
        case .guildMembersChunk(let guildMembersChunk):
            return guildMembersChunk as! T
        case .requestGuildMembers(let requestGuildMembers):
            return requestGuildMembers as! T
        case .guildRoleCreate(let guildRole):
            return guildRole as! T
        case .guildRoleUpdate(let guildRole):
            return guildRole as! T
        case .guildRoleDelete(let guildRoleDelete):
            return guildRoleDelete as! T
        case .guildScheduledEventCreate(let guildScheduledEvent):
            return guildScheduledEvent as! T
        case .guildScheduledEventUpdate(let guildScheduledEvent):
            return guildScheduledEvent as! T
        case .guildScheduledEventDelete(let guildScheduledEvent):
            return guildScheduledEvent as! T
        case .guildScheduledEventUserAdd(let guildScheduledEventUser):
            return guildScheduledEventUser as! T
        case .guildScheduledEventUserRemove(let guildScheduledEventUser):
            return guildScheduledEventUser as! T
        case .guildApplicationCommandIndexUpdate(let guildApplicationCommandIndexUpdate):
            return guildApplicationCommandIndexUpdate as! T
        case .guildJoinRequestUpdate(let guildJoinRequestUpdate):
            return guildJoinRequestUpdate as! T
        case .guildJoinRequestDelete(let guildJoinRequestDelete):
            return guildJoinRequestDelete as! T
        case .integrationCreate(let integration):
            return integration as! T
        case .integrationUpdate(let integration):
            return integration as! T
        case .integrationDelete(let integrationDelete):
            return integrationDelete as! T
        case .interactionCreate(let interaction):
            return interaction as! T
        case .inviteCreate(let inviteCreate):
            return inviteCreate as! T
        case .inviteDelete(let inviteDelete):
            return inviteDelete as! T
        case .messageCreate(let messageCreate):
            return messageCreate as! T
        case .messageUpdate(let partialMessage):
            return partialMessage as! T
        case .messageDelete(let messageDelete):
            return messageDelete as! T
        case .messageDeleteBulk(let messageDeleteBulk):
            return messageDeleteBulk as! T
        case .messageReactionAdd(let messageReactionAdd):
            return messageReactionAdd as! T
        case .messageReactionRemove(let messageReactionRemove):
            return messageReactionRemove as! T
        case .messageReactionRemoveAll(let messageReactionRemoveAll):
            return messageReactionRemoveAll as! T
        case .messageReactionRemoveEmoji(let messageReactionRemoveEmoji):
            return messageReactionRemoveEmoji as! T
        case .presenceUpdate(let presenceUpdate):
            return presenceUpdate as! T
        case .stageInstanceCreate(let stageInstance):
            return stageInstance as! T
        case .stageInstanceDelete(let stageInstance):
            return stageInstance as! T
        case .stageInstanceUpdate(let stageInstance):
            return stageInstance as! T
        case .typingStart(let typingStart):
            return typingStart as! T
        case .userUpdate(let discordUser):
            return discordUser as! T
        case .voiceStateUpdate(let voiceState):
            return voiceState as! T
        case .voiceServerUpdate(let voiceServerUpdate):
            return voiceServerUpdate as! T
        case .webhooksUpdate(let webhooksUpdate):
            return webhooksUpdate as! T
        case .applicationCommandPermissionsUpdate(let applicationCommandPermissionsUpdate):
            return applicationCommandPermissionsUpdate as! T
        case .autoModerationRuleCreate(let autoModerationRule):
            return autoModerationRule as! T
        case .autoModerationRuleUpdate(let autoModerationRule):
            return autoModerationRule as! T
        case .autoModerationActionExecution(let autoModerationActionExecution):
            return autoModerationActionExecution as! T
        }
    }
}

switch event.data {
case .none, .resumed:
    fatalError("No data to unwrap")
case .heartbeat(let lastSequenceNumber):
    return lastSequenceNumber as! T
case .identify(let identify):
    return identify as! T
case .hello(let hello):
    return hello as! T
case .ready(let ready):
    return ready as! T
case .resume(let resume):
    return resume as! T
case .invalidSession(let canResume):
    return canResume as! T
case .channelCreate(let discordChannel):
    return discordChannel as! T
case .channelUpdate(let discordChannel):
    return discordChannel as! T
case .channelDelete(let discordChannel):
    return discordChannel as! T
case .channelPinsUpdate(let channelPinsUpdate):
    return channelPinsUpdate as! T
case .threadCreate(let threadCreate):
    return threadCreate as! T
case .threadUpdate(let discordChannel):
    return discordChannel as! T
case .threadDelete(let threadDelete):
    return threadDelete as! T
case .threadSyncList(let threadListSync):
    return threadListSync as! T
case .threadMemberUpdate(let threadMemberUpdate):
    return threadMemberUpdate as! T
case .threadMembersUpdate(let threadMembersUpdate):
    return threadMembersUpdate as! T
case .guildCreate(let guild):
    return guild as! T
case .guildUpdate(let guild):
    return guild as! T
case .guildDelete(let unavailableGuild):
    return unavailableGuild as! T
case .guildBanAdd(let guildBan):
    return guildBan as! T
case .guildBanRemove(let guildBan):
    return guildBan as! T
case .guildEmojisUpdate(let guildEmojisUpdate):
    return guildEmojisUpdate as! T
case .guildStickersUpdate(let guildStickersUpdate):
    return guildStickersUpdate as! T
case .guildIntegrationsUpdate(let guildIntegrationsUpdate):
    return guildIntegrationsUpdate as! T
case .guildMemberAdd(let guildMemberAdd):
    return guildMemberAdd as! T
case .guildMemberRemove(let guildMemberRemove):
    return guildMemberRemove as! T
case .guildMemberUpdate(let guildMemberUpdate):
    return guildMemberUpdate as! T
case .guildMembersChunk(let guildMembersChunk):
    return guildMembersChunk as! T
case .requestGuildMembers(let requestGuildMembers):
    return requestGuildMembers as! T
case .guildRoleCreate(let guildRole):
    return guildRole as! T
case .guildRoleUpdate(let guildRole):
    return guildRole as! T
case .guildRoleDelete(let guildRoleDelete):
    return guildRoleDelete as! T
case .guildScheduledEventCreate(let guildScheduledEvent):
    return guildScheduledEvent as! T
case .guildScheduledEventUpdate(let guildScheduledEvent):
    return guildScheduledEvent as! T
case .guildScheduledEventDelete(let guildScheduledEvent):
    return guildScheduledEvent as! T
case .guildScheduledEventUserAdd(let guildScheduledEventUser):
    return guildScheduledEventUser as! T
case .guildScheduledEventUserRemove(let guildScheduledEventUser):
    return guildScheduledEventUser as! T
case .guildApplicationCommandIndexUpdate(let guildApplicationCommandIndexUpdate):
    return guildApplicationCommandIndexUpdate as! T
case .guildJoinRequestUpdate(let guildJoinRequestUpdate):
    return guildJoinRequestUpdate as! T
case .guildJoinRequestDelete(let guildJoinRequestDelete):
    return guildJoinRequestDelete as! T
case .integrationCreate(let integration):
    return integration as! T
case .integrationUpdate(let integration):
    return integration as! T
case .integrationDelete(let integrationDelete):
    return integrationDelete as! T
case .interactionCreate(let interaction):
    return interaction as! T
case .inviteCreate(let inviteCreate):
    return inviteCreate as! T
case .inviteDelete(let inviteDelete):
    return inviteDelete as! T
case .messageCreate(let messageCreate):
    return messageCreate as! T
case .messageUpdate(let partialMessage):
    return partialMessage as! T
case .messageDelete(let messageDelete):
    return messageDelete as! T
case .messageDeleteBulk(let messageDeleteBulk):
    return messageDeleteBulk as! T
case .messageReactionAdd(let messageReactionAdd):
    return messageReactionAdd as! T
case .messageReactionRemove(let messageReactionRemove):
    return messageReactionRemove as! T
case .messageReactionRemoveAll(let messageReactionRemoveAll):
    return messageReactionRemoveAll as! T
case .messageReactionRemoveEmoji(let messageReactionRemoveEmoji):
    return messageReactionRemoveEmoji as! T
case .presenceUpdate(let presenceUpdate):
    return presenceUpdate as! T
case .stageInstanceCreate(let stageInstance):
    return stageInstance as! T
case .stageInstanceDelete(let stageInstance):
    return stageInstance as! T
case .stageInstanceUpdate(let stageInstance):
    return stageInstance as! T
case .typingStart(let typingStart):
    return typingStart as! T
case .userUpdate(let discordUser):
    return discordUser as! T
case .voiceStateUpdate(let voiceState):
    return voiceState as! T
case .voiceServerUpdate(let voiceServerUpdate):
    return voiceServerUpdate as! T
case .webhooksUpdate(let webhooksUpdate):
    return webhooksUpdate as! T
case .applicationCommandPermissionsUpdate(let applicationCommandPermissionsUpdate):
    return applicationCommandPermissionsUpdate as! T
case .autoModerationRuleCreate(let autoModerationRule):
    return autoModerationRule as! T
case .autoModerationRuleUpdate(let autoModerationRule):
    return autoModerationRule as! T
case .autoModerationActionExecution(let autoModerationActionExecution):
    return autoModerationActionExecution as! T
    }
