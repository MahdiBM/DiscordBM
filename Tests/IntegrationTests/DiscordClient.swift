import DiscordBM
import AsyncHTTPClient
import Atomics
import NIOCore
import XCTest

class DiscordClientTests: XCTestCase {
    
    var httpClient: HTTPClient!
    var client: (any DiscordClient)!
    
    override func setUp() async throws {
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        self.client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            appId: Constants.botId
        )
    }
    
    override func tearDown() {
        try! self.httpClient.syncShutdown()
    }
    
    func testGateway() async throws {
        /// Get from "gateway"
        let url = try await client.getGateway().decode().url
        XCTAssertTrue(url.contains("wss://"), "payload: \(url)")
        XCTAssertTrue(url.contains("discord"), "payload: \(url)")
        
        /// Get from "bot gateway"
        let botInfo = try await client.getGatewayBot().decode()
        
        XCTAssertTrue(botInfo.url.contains("wss://"), "payload: \(botInfo)")
        XCTAssertTrue(botInfo.url.contains("discord"), "payload: \(botInfo)")
        let limitInfo = botInfo.session_start_limit
        let numbers = [
            limitInfo.max_concurrency,
            limitInfo.remaining,
            limitInfo.total
        ]
        XCTAssertTrue(numbers.allSatisfy({ $0 != 0 }), "payload: \(botInfo)")
    }
    
    func testMessageSendDelete() async throws {
        /// Create
        let text = "Testing! \(Date())"
        let message = try await client.createMessage(
            channelId: Constants.channelId,
            payload: .init(content: text)
        ).decode()
        
        XCTAssertEqual(message.content, text)
        XCTAssertEqual(message.channel_id, Constants.channelId)
        
        /// Edit
        let newText = "Edit Testing! \(Date())"
        let edited = try await client.editMessage(
            channelId: Constants.channelId,
            messageId: message.id,
            payload: .init(embeds: [
                .init(description: newText)
            ])
        ).decode()
        
        XCTAssertEqual(edited.content, text)
        XCTAssertEqual(edited.embeds.first?.description, newText)
        XCTAssertEqual(edited.channel_id, Constants.channelId)
        
        /// Add Reaction
        let reactionResponse = try await client.addReaction(
            channelId: Constants.channelId,
            messageId: message.id,
            emoji: "🚀"
        )
        
        XCTAssertEqual(reactionResponse.status, .noContent)
        
        /// Get the message again
        let retrievedMessage = try await client.getChannelMessage(
            channelId: Constants.channelId,
            messageId: message.id
        ).decode()
        
        XCTAssertEqual(retrievedMessage.id, edited.id)
        XCTAssertEqual(retrievedMessage.content, edited.content)
        XCTAssertEqual(retrievedMessage.channel_id, edited.channel_id)
        XCTAssertEqual(retrievedMessage.embeds.first?.description, edited.embeds.first?.description)
        
        /// Get channel messages
        let allMessages = try await client.getChannelMessages(
            channelId: Constants.channelId
        ).decode()
        
        XCTAssertEqual(allMessages.count, 3)
        XCTAssertEqual(allMessages[0].id, edited.id)
        XCTAssertEqual(allMessages[1].content, "And this is another test message :\\)")
        XCTAssertEqual(allMessages[2].content, "Hello! This is a test message!")
        
        /// Get channel messages with `limit == 2`
        let allMessagesLimit = try await client.getChannelMessages(
            channelId: Constants.channelId,
            limit: 2
        ).decode()
        
        XCTAssertEqual(allMessagesLimit.count, 2)
        
        /// Get channel messages with `after`
        let allMessagesAfter = try await client.getChannelMessages(
            channelId: Constants.channelId,
            after: allMessages[1].id
        ).decode()
        
        XCTAssertEqual(allMessagesAfter.count, 1)
        
        /// Get channel messages with `before`
        let allMessagesBefore = try await client.getChannelMessages(
            channelId: Constants.channelId,
            before: allMessages[2].id
        ).decode()
        
        XCTAssertEqual(allMessagesBefore.count, 0)
        
        /// Get channel messages with `around`
        let allMessagesAround = try await client.getChannelMessages(
            channelId: Constants.channelId,
            around: allMessages[1].id
        ).decode()
        
        XCTAssertEqual(allMessagesAround.count, 3)
        
        /// Delete
        let deletionResponse = try await client.deleteMessage(
            channelId: Constants.channelId,
            messageId: message.id
        )
        
        XCTAssertEqual(deletionResponse.status, .noContent)
    }
    
    func testSlashCommands() async throws {
        /// Create
        let commandName = "test-command"
        let commandDesc = "Testing!"
        let command = try await client.createApplicationGlobalCommand(
            appId: Constants.botId,
            payload: .init(name: commandName, description: commandDesc)
        ).decode()
        
        XCTAssertEqual(command.name, commandName)
        XCTAssertEqual(command.description, commandDesc)
        
        /// Get all
        let allCommands = try await client.getApplicationGlobalCommands().decode()
        
        XCTAssertEqual(allCommands.count, 1)
        let retrievedCommand = try XCTUnwrap(allCommands.first)
        XCTAssertEqual(retrievedCommand.name, commandName)
        XCTAssertEqual(retrievedCommand.description, commandDesc)
        
        /// Delete
        let commandId = try XCTUnwrap(retrievedCommand.id)
        let deletionResponse = try await client.deleteApplicationGlobalCommand(
            id: commandId
        )
        XCTAssertEqual(deletionResponse.status, .noContent)
    }
    
    func testGuildAndChannel() async throws {
        /// Get
        let guild = try await client.getGuild(
            id: Constants.guildId,
            withCounts: false
        ).decode()
        
        XCTAssertEqual(guild.id, Constants.guildId)
        XCTAssertEqual(guild.name, Constants.guildName)
        XCTAssertEqual(guild.approximate_member_count, nil)
        XCTAssertEqual(guild.approximate_presence_count, nil)
        
        /// Get with counts
        let guildWithCounts = try await client.getGuild(
            id: Constants.guildId,
            withCounts: true
        ).decode()
        
        XCTAssertEqual(guildWithCounts.id, Constants.guildId)
        XCTAssertEqual(guildWithCounts.name, Constants.guildName)
        XCTAssertEqual(guildWithCounts.approximate_member_count, 3)
        XCTAssertNotEqual(guildWithCounts.approximate_presence_count, nil)
        
        /// Get guild audit logs
        let _auditLogs = try await client.getGuildAuditLogs(guildId: Constants.guildId)
        
        var body = _auditLogs.httpResponse.body!
        let data = body.readData(length: body.readableBytes)!
        print(String(data: data, encoding: .utf8)!)
        
        let auditLogs = try _auditLogs.decode()
        print("----------------------------------------------------------------------")
        dump(auditLogs, maxDepth: 10)
        print("----------------------------------------------------------------------")
        XCTAssertFalse(auditLogs.audit_log_entries.isEmpty)
        
        /// Leave guild
        /// Can't leave guild so will just do a bad-request
        let leaveGuild = try await client.leaveGuild(id: Constants.guildId + "1111")
        
        XCTAssertEqual(leaveGuild.status, .badRequest)
        
        /// Get channel
        let channel = try await client.getChannel(id: Constants.channelId).decode()
        
        XCTAssertEqual(channel.id, Constants.channelId)
        
        /// Get member
        let member = try await client.getGuildMember(
            guildId: Constants.guildId,
            userId: Constants.personalId
        ).decode()
        
        XCTAssertEqual(member.user?.id, Constants.personalId)
        
        /// Search Guild members
        let search = try await client.searchGuildMembers(
            guildId: Constants.guildId,
            query: "Mahdi",
            limit: nil
        ).decode()
        
        XCTAssertTrue([1, 2].contains(search.count))
        XCTAssertTrue(search.allSatisfy({ $0.user?.username.contains("Mahdi") == true }))
        
        /// Search Guild members with invalid limit
        do {
            _ = try await client.searchGuildMembers(
                guildId: Constants.guildId,
                query: "Mahdi",
                limit: 10_000
            )
            XCTFail("'searchGuildMembers' must fail with too-big limits")
        } catch {
            switch error {
            case DiscordClientError.queryParameterOutOfBounds(
                name: "limit",
                value: "10000",
                lowerBound: 1,
                upperBound: 1_000
            ):
                break
            default:
                XCTFail("Unexpected fail error: \(error)")
            }
        }
        
        /// Create new role
        let rolePayload = CreateGuildRole(
            name: "test_role",
            permissions: [.addReactions, .attachFiles, .banMembers, .changeNickname],
            color: .init(red: 100, green: 100, blue: 100)!,
            hoist: true,
            unicode_emoji: nil, // Needs a boosted server
            mentionable: true
        )
        let role = try await client.createGuildRole(
            guildId: Constants.guildId,
            payload: rolePayload
        ).decode()
        
        XCTAssertEqual(role.name, rolePayload.name)
        XCTAssertEqual(role.permissions.toBitValue(), rolePayload.permissions!.toBitValue())
        XCTAssertEqual(role.color.value, rolePayload.color!.value)
        XCTAssertEqual(role.hoist, rolePayload.hoist)
        XCTAssertEqual(role.unicode_emoji, rolePayload.unicode_emoji)
        XCTAssertEqual(role.mentionable, rolePayload.mentionable)
        
        let memberRoleAdditionResponse = try await client.addGuildMemberRole(
            guildId: Constants.guildId,
            userId: Constants.personalId,
            roleId: role.id
        )
        
        XCTAssertEqual(memberRoleAdditionResponse.status, .noContent)
        
        let memberRoleDeletionResponse = try await client.removeGuildMemberRole(
            guildId: Constants.guildId,
            userId: Constants.personalId,
            roleId: role.id
        )
        
        XCTAssertEqual(memberRoleDeletionResponse.status, .noContent)
        
        /// Delete role
        let roleDeletionResponse = try await client.deleteGuildRole(
            guildId: Constants.guildId,
            roleId: role.id
        )
        
        XCTAssertEqual(roleDeletionResponse.status, .noContent)
    }
    
    /// Just here to keep track of un-tested interaction endpoints.
    /// We can't initiate interactions with automations (not officially at least), so can't test.
    func testInteractions() {
        /*
        createInteractionResponse(
            id: String,
            token: String,
            payload: InteractionResponse
        )
         
        editInteractionResponse(
            appId: String? = nil,
            token: String,
            payload: InteractionResponse.CallbackData
        )
         
        deleteInteractionResponse(
            appId: String? = nil,
            token: String
        )
         
        createFollowupInteractionResponse(
            appId: String? = nil,
            token: String,
            payload: InteractionResponse
        )
         
        editFollowupInteractionResponse(
            appId: String? = nil,
            id: String,
            token: String,
            payload: InteractionResponse
        )
        */
    }
    
    func testMultipartPayload() async throws {
        let image = ByteBuffer(data: resource(name: "discord-logo-blue.png"))
        
        do {
            let response = try await self.client.createMessage(
                channelId: Constants.secondChannelId,
                payload: .init(
                    content: "Multipart message!",
                    files: [.init(data: image, filename: "discord-logo.png")],
                    attachments: [.init(index: 0, description: "Test attachment!")]
                )
            ).decode()
            
            XCTAssertEqual(response.content, "Multipart message!")
            XCTAssertEqual(response.attachments.count, 1)
            
            let attachment = try XCTUnwrap(response.attachments.first)
            XCTAssertEqual(attachment.filename, "discord-logo.png")
            XCTAssertEqual(attachment.description, "Test attachment!")
            XCTAssertEqual(attachment.content_type, "image/png")
            XCTAssertEqual(attachment.size, 10731)
            XCTAssertEqual(attachment.height, 240)
            XCTAssertEqual(attachment.width, 876)
            XCTAssertFalse(attachment.id.isEmpty)
            XCTAssertFalse(attachment.url.isEmpty)
            XCTAssertFalse(attachment.proxy_url.isEmpty)
        }
        
        do {
            let response = try await self.client.createMessage(
                channelId: Constants.secondChannelId,
                payload: .init(
                    content: "Multipart message!",
                    embeds: [.init(
                        title: "Multipart embed!",
                        image: .init(url: .attachment(name: "discord-logo.png"))
                    )],
                    files: [.init(data: image, filename: "discord-logo.png")]
                )
            ).decode()
            
            XCTAssertEqual(response.content, "Multipart message!")
            XCTAssertEqual(response.attachments.count, 0)
            
            let image = try XCTUnwrap(response.embeds.first?.image)
            XCTAssertEqual(image.height, 240)
            XCTAssertEqual(image.width, 876)
            XCTAssertFalse(image.url.asString.isEmpty)
            XCTAssertFalse(image.proxy_url?.isEmpty == true)
        }
    }
    
    /// Rate-limiting has theoretical tests too, but this tests it in a practical situation.
    func testRateLimitedInPractice() async throws {
        let content = "Spamming! \(Date())"
        let rateLimitedErrors = ManagedAtomic(0)
        let count = 15
        let container = Container(targetCounter: count)
        
        let isFirstRequest = ManagedAtomic(false)
        Task {
            for _ in 0..<count {
                let isFirst = isFirstRequest.load(ordering: .relaxed)
                isFirstRequest.store(false, ordering: .relaxed)
                do {
                    _ = try await self.client.createMessage(
                        channelId: Constants.secondChannelId,
                        payload: .init(content: content)
                    ).decode()
                    await container.increaseCounter()
                } catch {
                    await container.increaseCounter()
                    switch error {
                    case DiscordClientError.rateLimited:
                        rateLimitedErrors.wrappingIncrement(ordering: .relaxed)
                    case DiscordClientError.cantAttemptToDecodeDueToBadStatusCode(let response)
                        where response.status == .tooManyRequests:
                        /// If its the first request and we're having this error, then
                        /// it means the last tests have exhausted our rate-limit and
                        /// it's not this test's fault.
                        if isFirst {
                            break
                        } else {
                            fallthrough
                        }
                    default:
                        XCTFail("Received unexpected error: \(error)")
                    }
                }
            }
        }
        
        await container.waitForCounter()
        
        XCTAssertGreaterThan(rateLimitedErrors.load(ordering: .relaxed), 0)
        
        /// Waiting 5 seconds to make sure the next tests don't get rate-limited
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
}

private actor Container {
    private var counter = 0
    private var targetCounter: Int
    
    init(targetCounter: Int) {
        self.targetCounter = targetCounter
    }
    
    func increaseCounter() {
        counter += 1
        if counter == targetCounter {
            waiter?.resume()
            waiter = nil
        }
    }
    
    private var waiter: CheckedContinuation<(), Never>?
    
    func waitForCounter() async {
        await withCheckedContinuation {
            waiter = $0
        }
        Task {
            try await Task.sleep(nanoseconds: 10_000_000_000)
            if waiter != nil {
                waiter?.resume()
                XCTFail("Failed to test in-time")
            }
        }
    }
}
