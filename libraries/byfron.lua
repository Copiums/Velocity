--[[

    ____   ____     .__                .__  __          
    \   \ /   /____ |  |   ____   ____ |__|/  |_ ___.__.
     \   Y   // __ \|  |  /  _ \_/ ___\|  \   __<   |  |
      \     /\  ___/|  |_(  <_> )  \___|  ||  |  \___  |
       \___/  \___  >____/\____/ \___  >__||__|  / ____|
                  \/                 \/          \/      

       The #1 Roblox Script on the Market.


		- copium - modules

	Velocity Roblox suspension page (NotApprovedPageV2) - local preview.
	The page modules below are Roblox's own code, decompiled from the app bundle
	(UniversalApp.rbxm -> LuauForgeChunks.deferred). Only the network, analytics,
	link and logout pieces are swapped for offline stubs, so nothing is sent anywhere.
    Obv half made by claude cuz im too lazy asf
]]

local CONFIG = {
	punishmentType = "Delete", -- "Delete" = permanent; or "Warn", "Ban 1 Day", "Ban 3 Days", "Ban 7 Days", "Ban 14 Days", ...
	moderatorNote  = "We noticed a modified version of Roblox was used on a device you recently played on. This poses safety and security risks and is not allowed. Please uninstall any unofficial versions and reinstall Roblox from our website or official app stores on all your devices. Continued use of modified versions may lead to more account restrictions, including account termination.",
	reviewedAgoSeconds = 0,               -- "Review date" = now minus this (0 = current time, shown in your local time zone)
	durationSeconds    = 7 * 24 * 3600,   -- suspension end = review date plus this
	interventionId     = nil,             -- nil = random id
	colorMode          = "Auto",          -- "Auto" = follow the Roblox theme setting, or force "Light" / "Dark"
	closeKey           = Enum.KeyCode.RightControl,
}

local LOG_FILE = "ban_page_log.txt"
local logLines = {}
local function log(...)
	local p = {}
	for i = 1, select("#", ...) do p[i] = tostring((select(i, ...))) end
	table.insert(logLines, table.concat(p, " "))
	if writefile then pcall(writefile, LOG_FILE, table.concat(logLines, "\n")) end
end

local CorePackages = game:GetService("CorePackages")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local req = (getrenv and getrenv().require) or require

local function pkg(...)
	local cur = CorePackages
	for _, name in { ... } do
		cur = cur and cur:FindFirstChild(name)
	end
	if not cur then error("missing package: " .. table.concat({ ... }, "."), 2) end
	return req(cur)
end

local React = pkg("Packages", "React")
local ReactRoblox = pkg("Packages", "ReactRoblox")
local Foundation = pkg("Packages", "Foundation")
local Cryo = pkg("Packages", "Cryo")
local Promise = pkg("Packages", "Promise")
local function optional(...)
	local ok, v = pcall(pkg, ...)
	if not ok then log("optional package unavailable:", table.concat({ ... }, "."), v) end
	return ok and v or nil
end
local UrlBuilderPkg = optional("Packages", "UrlBuilder")
local tPkg = optional("Packages", "t")
local BuilderIcons = optional("Packages", "BuilderIcons")
local InputHandlers = optional("Packages", "InputHandlers")
local SharedFlagsReal = optional("Workspace", "Packages", "SharedFlags")

-- English strings (subset of the app's en-us table) ---------------------------
local EN = {
	["Application.Logout.Action.Logout"] = "Log Out",
	["Application.Logout.Message.Confirmation"] = "Are you sure you want to log out?",
	["Application.Logout.Title.Logout"] = "Log Out",
	["CommonUI.Controls.Action.Accept"] = "Accept",
	["CommonUI.Controls.Action.Apply"] = "Apply",
	["CommonUI.Controls.Action.Back"] = "Back",
	["CommonUI.Controls.Action.Cancel"] = "Cancel",
	["CommonUI.Controls.Action.CloseRoblox"] = "Close Roblox",
	["CommonUI.Controls.Action.Confirm"] = "Confirm",
	["CommonUI.Controls.Action.Continue"] = "Continue",
	["CommonUI.Controls.Action.Done"] = "Done",
	["CommonUI.Controls.Action.Next"] = "Next",
	["CommonUI.Controls.Action.OK"] = "OK",
	["CommonUI.Controls.Action.Refresh"] = "Refresh",
	["CommonUI.Controls.Action.ResetAll"] = "Reset all",
	["CommonUI.Controls.Action.Search"] = "Search",
	["CommonUI.Controls.Action.ShowMore"] = "Show more",
	["CommonUI.Controls.Action.Submit"] = "Submit",
	["CommonUI.Controls.Action.Yes"] = "Yes",
	["CommonUI.Controls.Birthdaypicker.Label.Date"] = "Date",
	["CommonUI.Controls.Input.Optional"] = "{inputLabel} (optional)",
	["CommonUI.Controls.Label.April"] = "April",
	["CommonUI.Controls.Label.AprilAbbreviated"] = "Apr",
	["CommonUI.Controls.Label.August"] = "August",
	["CommonUI.Controls.Label.AugustAbbreviated"] = "Aug",
	["CommonUI.Controls.Label.BetaProgramUpdateMessage"] = "Your account is enrolled in a beta program. Please restart to apply the program-specific configuration.",
	["CommonUI.Controls.Label.ChannelConfigurationUpdateMessage"] = "Your account is enrolled in an internal Roblox Channel. Please restart to apply the channel-specific configuration.",
	["CommonUI.Controls.Label.Day"] = "Day",
	["CommonUI.Controls.Label.December"] = "December",
	["CommonUI.Controls.Label.DecemberAbbreviated"] = "Dec",
	["CommonUI.Controls.Label.February"] = "February",
	["CommonUI.Controls.Label.FebruaryAbbreviated"] = "Feb",
	["CommonUI.Controls.Label.ForceUpdateBody"] = "Roblox needs to restart to update. Please relaunch Roblox.",
	["CommonUI.Controls.Label.ForceUpdateTitle"] = "Update Required",
	["CommonUI.Controls.Label.Friday"] = "Friday",
	["CommonUI.Controls.Label.FridayAbbreviated"] = "Fr",
	["CommonUI.Controls.Label.InvalidDateFormat"] = "Invalid date format",
	["CommonUI.Controls.Label.January"] = "January",
	["CommonUI.Controls.Label.JanuaryAbbreviated"] = "Jan",
	["CommonUI.Controls.Label.July"] = "July",
	["CommonUI.Controls.Label.June"] = "June",
	["CommonUI.Controls.Label.LastWeek"] = "Last week",
	["CommonUI.Controls.Label.LastYear"] = "Last year",
	["CommonUI.Controls.Label.March"] = "March",
	["CommonUI.Controls.Label.MarchAbbreviated"] = "Mar",
	["CommonUI.Controls.Label.May"] = "May",
	["CommonUI.Controls.Label.Monday"] = "Monday",
	["CommonUI.Controls.Label.MondayAbbreviated"] = "Mo",
	["CommonUI.Controls.Label.Month"] = "Month",
	["CommonUI.Controls.Label.November"] = "November",
	["CommonUI.Controls.Label.NovemberAbbreviated"] = "Nov",
	["CommonUI.Controls.Label.October"] = "October",
	["CommonUI.Controls.Label.OctoberAbbreviated"] = "Oct",
	["CommonUI.Controls.Label.PageCount"] = "{current:int} of {total:int}",
	["CommonUI.Controls.Label.Saturday"] = "Saturday",
	["CommonUI.Controls.Label.SaturdayAbbreviated"] = "Sa",
	["CommonUI.Controls.Label.SelectDate"] = "Select date",
	["CommonUI.Controls.Label.SelectTheTime"] = "Select the time",
	["CommonUI.Controls.Label.September"] = "September",
	["CommonUI.Controls.Label.SeptemberAbbreviated"] = "Sept",
	["CommonUI.Controls.Label.Sunday"] = "Sunday",
	["CommonUI.Controls.Label.SundayAbbreviated"] = "Su",
	["CommonUI.Controls.Label.ThisMonth"] = "This month",
	["CommonUI.Controls.Label.ThisWeek"] = "This week",
	["CommonUI.Controls.Label.ThisYear"] = "This year",
	["CommonUI.Controls.Label.Thursday"] = "Thursday",
	["CommonUI.Controls.Label.ThursdayAbbreviated"] = "Th",
	["CommonUI.Controls.Label.Today"] = "Today",
	["CommonUI.Controls.Label.Tuesday"] = "Tuesday",
	["CommonUI.Controls.Label.TuesdayAbbreviated"] = "Tu",
	["CommonUI.Controls.Label.Wednesday"] = "Wednesday",
	["CommonUI.Controls.Label.WednesdayAbbreviated"] = "We",
	["CommonUI.Controls.Label.Year"] = "Year",
	["CommonUI.Controls.NoResultsFound"] = "No results found",
	["CommonUI.Features.Action.Close"] = "Close",
	["CommonUI.Features.Action.Go"] = "Go",
	["CommonUI.Features.Action.LessLowercase"] = "less",
	["CommonUI.Features.Action.MoreLowercase"] = "more",
	["CommonUI.Features.Action.Send"] = "Send",
	["CommonUI.Features.Heading.GameDetails"] = "Experience Details",
	["CommonUI.Features.Label.About"] = "About",
	["CommonUI.Features.Label.AboutUs"] = "About Us",
	["CommonUI.Features.Label.AcceptFriend"] = "Accept Friend",
	["CommonUI.Features.Label.AddConnections"] = "Add Connections",
	["CommonUI.Features.Label.AddFriend"] = "Add Friend",
	["CommonUI.Features.Label.AdjustScreen"] = "Adjust Screen",
	["CommonUI.Features.Label.AppInformation"] = "App information",
	["CommonUI.Features.Label.Avatar"] = "Avatar",
	["CommonUI.Features.Label.Badges"] = "Badges",
	["CommonUI.Features.Label.Careers"] = "Careers",
	["CommonUI.Features.Label.Catalog"] = "Roblox Catalog",
	["CommonUI.Features.Label.ChannelWithChannelName"] = "Channel: {channelName}",
	["CommonUI.Features.Label.Charts"] = "Charts",
	["CommonUI.Features.Label.Chat"] = "Chat",
	["CommonUI.Features.Label.ClientCoreScriptVersion"] = "Client-CoreScript-Version: {clientCoreScriptVersion}",
	["CommonUI.Features.Label.Connections"] = "Connections",
	["CommonUI.Features.Label.ControllerBar.HoldPrefix"] = "Hold",
	["CommonUI.Features.Label.ControllerBar.Search"] = "Search",
	["CommonUI.Features.Label.ControllerBar.ToPlaySuffix"] = "to play",
	["CommonUI.Features.Label.CreateGames"] = "Create",
	["CommonUI.Features.Label.CreationCenter"] = "Creation Center",
	["CommonUI.Features.Label.DevSubs"] = "Subscriptions",
	["CommonUI.Features.Label.Discover"] = "Discover",
	["CommonUI.Features.Label.ForYou"] = "For you",
	["CommonUI.Features.Label.Friends"] = "Friends",
	["CommonUI.Features.Label.Game"] = "Experiences",
	["CommonUI.Features.Label.Games"] = "Games",
	["CommonUI.Features.Label.GiftCards"] = "Buy Gift Cards",
	["CommonUI.Features.Label.Groups"] = "Communities",
	["CommonUI.Features.Label.Help"] = "Help",
	["CommonUI.Features.Label.HelpAndSafety"] = "Help & Safety",
	["CommonUI.Features.Label.Home"] = "Home",
	["CommonUI.Features.Label.Inventory"] = "Inventory",
	["CommonUI.Features.Label.Learn"] = "Learn",
	["CommonUI.Features.Label.Licensing"] = "Licensing",
	["CommonUI.Features.Label.LuobuRiderTerms"] = "Luobu Rider Terms",
	["CommonUI.Features.Label.LuobuThirdPartyDataUse"] = "Third party share list",
	["CommonUI.Features.Label.Me"] = "Me",
	["CommonUI.Features.Label.Messages"] = "Messages",
	["CommonUI.Features.Label.Moments"] = "Moments",
	["CommonUI.Features.Label.More"] = "More",
	["CommonUI.Features.Label.MoreEvents"] = "More events coming soon!",
	["CommonUI.Features.Label.Newsroom"] = "Newsroom",
	["CommonUI.Features.Label.OfficialStore"] = "Official Store",
	["CommonUI.Features.Label.Parents"] = "Parents",
	["CommonUI.Features.Label.Players"] = "People",
	["CommonUI.Features.Label.Premium"] = "Premium",
	["CommonUI.Features.Label.Privacy"] = "Privacy",
	["CommonUI.Features.Label.PrivacyGuidelinesChildren"] = "Privacy Guidelines for Children",
	["CommonUI.Features.Label.PrivacyPolicy"] = "Privacy Policy",
	["CommonUI.Features.Label.Profile"] = "Profile",
	["CommonUI.Features.Label.RM"] = "Moments",
	["CommonUI.Features.Label.Redeem"] = "Redeem Codes",
	["CommonUI.Features.Label.ReportLogs"] = "Report Logs",
	["CommonUI.Features.Label.ReportLogsSentenceCase"] = "Report logs",
	["CommonUI.Features.Label.Settings"] = "Settings",
	["CommonUI.Features.Label.Startup"] = "Startup",
	["CommonUI.Features.Label.SupportCenter"] = "Experience Support History",
	["CommonUI.Features.Label.TencentNotice"] = "Notice",
	["CommonUI.Features.Label.Terms"] = "Terms",
	["CommonUI.Features.Label.TermsOfService"] = "Terms of Service",
	["CommonUI.Features.Label.TermsOfUse"] = "Terms of Use",
	["CommonUI.Features.Label.Thanks"] = "Thanks",
	["CommonUI.Features.Label.TheHunt"] = "Roblox Events",
	["CommonUI.Features.Label.Trades"] = "Trades",
	["CommonUI.Features.Label.Unchecked"] = "Unchecked",
	["CommonUI.Features.Label.VNGMigrationBody"] = "To continue using Roblox in your region, please download the new Roblox-VNG app and sign in with your Roblox user name.",
	["CommonUI.Features.Label.VNGMigrationBodyPC"] = "To continue using Roblox in your region, please download the new Roblox - VN app and sign in with your Roblox user name.",
	["CommonUI.Features.Label.VNGMigrationGoButton"] = "Go to Roblox-VNG App",
	["CommonUI.Features.Label.VNGMigrationGoButtonPC"] = "Go to Roblox - VN App",
	["CommonUI.Features.Label.VNGMigrationTip"] = "Pro Tip: Select “Quick Log In” in the Roblox-VNG app for easier sign-in.",
	["CommonUI.Features.Label.VNGMigrationTitle"] = "Roblox is now Roblox-VNG!",
	["CommonUI.Features.Label.VNGMigrationTitlePC"] = "Roblox is now Roblox - VN!",
	["CommonUI.Features.Label.VRFTUX"] = "VR Tutorial",
	["CommonUI.Features.Label.Version"] = "Version",
	["CommonUI.Features.Label.VersionWithNumber"] = "Version: {versionNumber}",
	["CommonUI.Features.Label.X"] = "Roblox Plus",
	["CommonUI.Features.Label.sGroups"] = "Communities",
	["CommonUI.Features.Labels.ConnectTo"] = "Connect to",
	["CommonUI.Features.Labels.OrYouCan"] = "Or you can",
	["CommonUI.Features.Labels.Retry"] = "Retry",
	["CommonUI.Features.Labels.ServerCommunicationError"] = "There was an error when communicating with Roblox servers.",
	["CommonUI.Features.Labels.With"] = "With",
	["CommonUI.Features.NavBar.Build"] = "Build",
	["CommonUI.Features.Prompt.ReportLogsQuestion"] = "Send your local log file to Backtrace?",
	["CommonUI.Features.Prompt.ReportLogsResult"] = "Report sent.",
	["CommonUI.Features.StudioCTA.Tooltip.Body"] = "Download Studio for FREE!",
	["CommonUI.Features.StudioCTA.Tooltip.Title"] = "Start creating on Roblox",
	["Feature.AppealsPortal.Action.AskForReview"] = "Ask for review",
	["Feature.AppealsPortal.Action.FinalAppeal"] = "Send final appeal",
	["Feature.AppealsPortal.Action.OK"] = "OK",
	["Feature.AppealsPortal.Action.Send"] = "Send",
	["Feature.AppealsPortal.Action.SendAppeal"] = "Send appeal",
	["Feature.AppealsPortal.Description"] = "More details about this violation aren’t available.",
	["Feature.AppealsPortal.Description.AppealAccepted.Multiple"] = "We reviewed your appeal for {violationsList}, and {singleViolation} and we found that your activity didn’t break the rules explained in our Community Standards – so there are no consequences to your account. This will help us improve our reviews — thanks!",
	["Feature.AppealsPortal.Description.AppealAccepted.None"] = "We reviewed your appeal and we found that your activity didn’t break the rules explained in our Community Standards – so there are no consequences to your account. This will help us improve our reviews — thanks!",
	["Feature.AppealsPortal.Description.AppealAccepted.V2"] = "We reviewed your appeal for {violations} and we found that your activity didn’t break the rules explained in our Community Standards – so there are no consequences to your account. This will help us improve our reviews — thanks!",
	["Feature.AppealsPortal.Description.AppealDenied.Multiple"] = "We carefully reviewed your appeal for {violationsList}, and {singleViolation} and we still consider that your activity breaks the rules explained in our Community Standards. We understand this decision can feel disappointing, and appreciate your time sending an appeal.",
	["Feature.AppealsPortal.Description.AppealDenied.None"] = "We carefully reviewed your appeal and we still consider that your activity breaks the rules explained in our Community Standards. We understand this decision can feel disappointing, and appreciate your time sending an appeal.",
	["Feature.AppealsPortal.Description.AppealDenied.Singular"] = "We carefully reviewed your appeal for {singleViolation} and we still consider that your activity breaks the rules explained in our Community Standards. We understand this decision can feel disappointing, and appreciate your time sending an appeal.",
	["Feature.AppealsPortal.Description.AppealDenied.V2"] = "We carefully reviewed your appeal for {violations} and we still consider that your activity breaks the rules explained in our Community Standards. Thanks for sending an appeal.",
	["Feature.AppealsPortal.Description.AppealDisclosures"] = "{link}View appeal guidelines and disclosures{linkEnd}",
	["Feature.AppealsPortal.Description.AppealIneligible"] = "You\'re no longer eligible to appeal this decision. Please verify your identity and try again.",
	["Feature.AppealsPortal.Description.AppealReceived"] = "We’ll let you know of a decision soon. We estimate a response within 5 business days, depending on how complex the issue is. Thanks for sending an appeal.",
	["Feature.AppealsPortal.Description.AppealReceived.Plural"] = "We’ll let you know of a decision soon. We estimate a response within {number} business days, depending on how complex the issue is. Thanks for sending an appeal.",
	["Feature.AppealsPortal.Description.AppealReceived.Singular"] = "We’ll let you know of a decision soon. We estimate a response within 1 business day, depending on how complex the issue is. Thanks for sending an appeal.",
	["Feature.AppealsPortal.Description.AppealRequiresIdv"] = "You need to verify your identity to appeal this decision. If you\'ve verified your ID already, we may use that.",
	["Feature.AppealsPortal.Description.AppealSubmitted"] = "IGNORE - NOT NEEDED",
	["Feature.AppealsPortal.Description.AppealSubmittedComplexity"] = "The actual time depends on many factors, including the complexity of the issues raised and how much relevant information you included.",
	["Feature.AppealsPortal.Description.AppealSubmittedDecisionTime"] = "We estimate a decision within 5 business days.",
	["Feature.AppealsPortal.Description.AppealSubmittedDecisionTime.Plural"] = "We estimate a decision within {number} business days.",
	["Feature.AppealsPortal.Description.AppealSubmittedDecisionTime.Singular"] = "We estimate a decision within 1 business day.",
	["Feature.AppealsPortal.Description.AppealSubmittedUpdate"] = "We’ll send an update with our decision and any action taken to the email address you provided.",
	["Feature.AppealsPortal.Description.AppealSubmittedUpdate.OptOut"] = "We’ll send an update with our decision and any action taken to the email address you provided, unless you told us you don’t want more communications about this appeal.",
	["Feature.AppealsPortal.Description.AppealsPortal"] = "View past violations and manage your appeals. All content and behavior must adhere to the {link}Roblox Community Standards.{linkEnd}",
	["Feature.AppealsPortal.Description.AskForReview"] = "You\'re confirming that you\'ve fixed this issue. We\'ll review this {contentType} again.",
	["Feature.AppealsPortal.Description.DetailsUnavailable"] = "More details about this violation aren’t available.",
	["Feature.AppealsPortal.Description.FixByDate"] = "Fix the issue in Studio by {date}, then come back and ask for review.",
	["Feature.AppealsPortal.Description.IssueClosed"] = "We closed this issue because you decided to learn one of our rules to avoid a suspension.",
	["Feature.AppealsPortal.Description.MatchEmail"] = "Emails must match.",
	["Feature.AppealsPortal.Description.MiscAppeal"] = "Tell us if you think we made a mistake.",
	["Feature.AppealsPortal.Description.MiscAppealLink"] = "Appeal a decision you don’t see here",
	["Feature.AppealsPortal.Description.NoCommunications"] = "You chose to not receive any communications about this appeal",
	["Feature.AppealsPortal.Description.OneAppeal"] = "By selecting Send, you confirm that this information is true and that you\'re only sending one appeal about this decision.",
	["Feature.AppealsPortal.Description.OtherWarning"] = "To ensure review, only use Other when your appeal doesn\'t fit any other choice. We\'ll close appeals sent under the wrong category.",
	["Feature.AppealsPortal.Description.RequestAppealReview.V3"] = "Reviews are based on {link}Roblox Community Standards{linkEnd}.",
	["Feature.AppealsPortal.Description.RequiredField"] = "This field is required.",
	["Feature.AppealsPortal.Description.VerifyIdentityToAppeal"] = "This helps us determine whether this account should be linked to the banned account.",
	["Feature.AppealsPortal.Description.ViolationInactive"] = "We closed this issue because no further action is needed.",
	["Feature.AppealsPortal.Header.AppealAccepted"] = "We accepted an appeal you sent",
	["Feature.AppealsPortal.Header.AppealDenied"] = "We denied an appeal you sent",
	["Feature.AppealsPortal.Header.AppealReceived"] = "We received an appeal you sent",
	["Feature.AppealsPortal.Header.RequestAppeal"] = "Request appeal",
	["Feature.AppealsPortal.Header.ViolationInactive"] = "Violation resolved",
	["Feature.AppealsPortal.Heading.ActivityReviewed"] = "Activity we reviewed",
	["Feature.AppealsPortal.Heading.AppealDecision"] = "Appeal a decision",
	["Feature.AppealsPortal.Heading.AppealSubmitted"] = "We received your appeal",
	["Feature.AppealsPortal.Heading.AppealTimeline"] = "Appeal timeline",
	["Feature.AppealsPortal.Heading.AppealUnavailable"] = "Appeal unavailable",
	["Feature.AppealsPortal.Heading.MiscAppeal"] = "Appeal a decision you don’t see here",
	["Feature.AppealsPortal.Heading.VerifyIdentityToAppeal"] = "Let\'s verify your identity so you can send an appeal",
	["Feature.AppealsPortal.Heading.ViolationsAndAppeals"] = "Violations and appeals",
	["Feature.AppealsPortal.Label.AccessoryDescription"] = "Accessory Description",
	["Feature.AppealsPortal.Label.Account"] = "Account",
	["Feature.AppealsPortal.Label.ActivityReviewed"] = "Activity we reviewed",
	["Feature.AppealsPortal.Label.Ad"] = "Ad",
	["Feature.AppealsPortal.Label.AdId"] = "Ad ID",
	["Feature.AppealsPortal.Label.AltAccount"] = "Alt account",
	["Feature.AppealsPortal.Label.AppealComment"] = "Comment you sent:",
	["Feature.AppealsPortal.Label.AppealMessageCharacterCount"] = "{current}/{max} characters",
	["Feature.AppealsPortal.Label.AppealReason"] = "Why are you appealing?",
	["Feature.AppealsPortal.Label.AppealReason.Placeholder"] = "Tell us why you think we should change our decision.",
	["Feature.AppealsPortal.Label.AssetId"] = "Asset ID",
	["Feature.AppealsPortal.Label.AssetName"] = "Asset Name",
	["Feature.AppealsPortal.Label.AudioStartTime"] = "Audio start time",
	["Feature.AppealsPortal.Label.AvatarItem"] = "Avatar item",
	["Feature.AppealsPortal.Label.Billing"] = "Billing",
	["Feature.AppealsPortal.Label.BundleDescription"] = "Bundle Description",
	["Feature.AppealsPortal.Label.BundleId"] = "Bundle ID",
	["Feature.AppealsPortal.Label.BundleName"] = "Bundle Name",
	["Feature.AppealsPortal.Label.ChatEvidenceId"] = "Chat Evidence ID",
	["Feature.AppealsPortal.Label.Cheating"] = "Cheating",
	["Feature.AppealsPortal.Label.ContentMaturity"] = "Content Maturity Questionnaire Submission",
	["Feature.AppealsPortal.Label.DecisionCategory"] = "What kind of decision do you want to appeal?",
	["Feature.AppealsPortal.Label.DisplayName"] = "Display name",
	["Feature.AppealsPortal.Label.DropdownPlaceholder"] = "Select one",
	["Feature.AppealsPortal.Label.EmailConfirmation"] = "Confirm your email",
	["Feature.AppealsPortal.Label.EmailInput"] = "Your email",
	["Feature.AppealsPortal.Label.EmailOptOutCheckbox"] = "Check if you don’t want to receive any more communications about this appeal.",
	["Feature.AppealsPortal.Label.Experience.ContentMaturity"] = "Experience I own - Content maturity",
	["Feature.AppealsPortal.Label.Experience.Suspension"] = "Experience I own - Suspension",
	["Feature.AppealsPortal.Label.ExperienceIOwnContentMaturity"] = "Experience I own - Content maturity",
	["Feature.AppealsPortal.Label.ExperienceIOwnSuspension"] = "Experience I own - Suspension",
	["Feature.AppealsPortal.Label.ExperienceLinkPrompt"] = "Enter a link to your experience",
	["Feature.AppealsPortal.Label.ExploitDetected"] = "Device exploit detected",
	["Feature.AppealsPortal.Label.Group"] = "Group",
	["Feature.AppealsPortal.Label.ID"] = "ID",
	["Feature.AppealsPortal.Label.IDArg"] = "ID: {id}",
	["Feature.AppealsPortal.Label.ImageOrOtherAsset"] = "Image or other asset",
	["Feature.AppealsPortal.Label.ImmersiveBrandedAd"] = "Integrated Ad",
	["Feature.AppealsPortal.Label.ImmersiveBrandedAdPlacementId"] = "Integrated Ad Placement ID",
	["Feature.AppealsPortal.Label.InGameBehavior"] = "In-game behavior",
	["Feature.AppealsPortal.Label.InGameBehavior.Notice"] = "Chat or gameplay",
	["Feature.AppealsPortal.Label.Location"] = "Location",
	["Feature.AppealsPortal.Label.LookDescription"] = "Shared Avatar Description",
	["Feature.AppealsPortal.Label.LookId"] = "Shared Avatar ID",
	["Feature.AppealsPortal.Label.LookName"] = "Shared Avatar Name",
	["Feature.AppealsPortal.Label.PlaceIDPrompt"] = "What\'s the place ID?",
	["Feature.AppealsPortal.Label.PlaceId"] = "Place ID",
	["Feature.AppealsPortal.Label.PlaceName"] = "Place Name",
	["Feature.AppealsPortal.Label.ProfileDescription"] = "Profile description",
	["Feature.AppealsPortal.Label.Reason"] = "Reason",
	["Feature.AppealsPortal.Label.ReportAndAppeals"] = "Violations & Appeals",
	["Feature.AppealsPortal.Label.Type.Asset"] = "Asset",
	["Feature.AppealsPortal.Label.Type.Audio"] = "Audio",
	["Feature.AppealsPortal.Label.Type.Avatar"] = "Avatar",
	["Feature.AppealsPortal.Label.Type.AvatarAccessory"] = "Avatar Accessory",
	["Feature.AppealsPortal.Label.Type.AvatarAccessoryText"] = "Avatar Accessory Name and Description",
	["Feature.AppealsPortal.Label.Type.Bundle"] = "Bundle",
	["Feature.AppealsPortal.Label.Type.BundleText"] = "Bundle Name and Description",
	["Feature.AppealsPortal.Label.Type.Chat"] = "Chat",
	["Feature.AppealsPortal.Label.Type.CommerceProduct"] = "Commerce Product",
	["Feature.AppealsPortal.Label.Type.ContentMaturity"] = "Experience",
	["Feature.AppealsPortal.Label.Type.Experience"] = "Experience",
	["Feature.AppealsPortal.Label.Type.Game"] = "Game",
	["Feature.AppealsPortal.Label.Type.Image"] = "Image",
	["Feature.AppealsPortal.Label.Type.InGameBehavior"] = "In-game behavior",
	["Feature.AppealsPortal.Label.Type.Look"] = "Shared Avatar",
	["Feature.AppealsPortal.Label.Type.LookText"] = "Shared Avatar Name and Description",
	["Feature.AppealsPortal.Label.Type.Mesh"] = "Mesh",
	["Feature.AppealsPortal.Label.Type.Model"] = "Model",
	["Feature.AppealsPortal.Label.Type.Plugin"] = "Plugin",
	["Feature.AppealsPortal.Label.Type.Post"] = "Post",
	["Feature.AppealsPortal.Label.Type.Screenshot"] = "Screenshot",
	["Feature.AppealsPortal.Label.Type.UserProfile"] = "User profile",
	["Feature.AppealsPortal.Label.Type.Video"] = "Video",
	["Feature.AppealsPortal.Label.Type.Voice"] = "Voice Chat",
	["Feature.AppealsPortal.Label.TypeBrokeRules.Generic"] = "Your behavior broke the rules",
	["Feature.AppealsPortal.Label.TypeLower.Account"] = "account",
	["Feature.AppealsPortal.Label.TypeLower.Ad"] = "ad",
	["Feature.AppealsPortal.Label.TypeLower.AltAccount"] = "alt account",
	["Feature.AppealsPortal.Label.TypeLower.Asset"] = "asset",
	["Feature.AppealsPortal.Label.TypeLower.Audio"] = "audio",
	["Feature.AppealsPortal.Label.TypeLower.Avatar"] = "avatar",
	["Feature.AppealsPortal.Label.TypeLower.AvatarAccessory"] = "avatar accessory",
	["Feature.AppealsPortal.Label.TypeLower.AvatarAccessoryText"] = "avatar accessory name and description",
	["Feature.AppealsPortal.Label.TypeLower.Behavior"] = "behavior",
	["Feature.AppealsPortal.Label.TypeLower.Bundle"] = "bundle",
	["Feature.AppealsPortal.Label.TypeLower.BundleText"] = "bundle name and description",
	["Feature.AppealsPortal.Label.TypeLower.Chat"] = "chat",
	["Feature.AppealsPortal.Label.TypeLower.CommerceProduct"] = "commerce product",
	["Feature.AppealsPortal.Label.TypeLower.ContentMaturity"] = "experience",
	["Feature.AppealsPortal.Label.TypeLower.Experience"] = "experience",
	["Feature.AppealsPortal.Label.TypeLower.Game"] = "game",
	["Feature.AppealsPortal.Label.TypeLower.Image"] = "image",
	["Feature.AppealsPortal.Label.TypeLower.ImmersiveBrandedAd"] = "integrated ad",
	["Feature.AppealsPortal.Label.TypeLower.InGameBehavior"] = "in-game behavior",
	["Feature.AppealsPortal.Label.TypeLower.Look"] = "shared avatar",
	["Feature.AppealsPortal.Label.TypeLower.LookText"] = "shared avatar name and description",
	["Feature.AppealsPortal.Label.TypeLower.Mesh"] = "mesh",
	["Feature.AppealsPortal.Label.TypeLower.Model"] = "model",
	["Feature.AppealsPortal.Label.TypeLower.PlaceId"] = "place ID",
	["Feature.AppealsPortal.Label.TypeLower.Plugin"] = "plugin",
	["Feature.AppealsPortal.Label.TypeLower.Post"] = "post",
	["Feature.AppealsPortal.Label.TypeLower.Screenshot"] = "screenshot",
	["Feature.AppealsPortal.Label.TypeLower.UserProfile"] = "user profile",
	["Feature.AppealsPortal.Label.TypeLower.Video"] = "video",
	["Feature.AppealsPortal.Label.TypeLower.Voice"] = "voice chat",
	["Feature.AppealsPortal.Label.TypePlural.Asset"] = "assets",
	["Feature.AppealsPortal.Label.TypePlural.Audio"] = "audios",
	["Feature.AppealsPortal.Label.TypePlural.Avatar"] = "avatars",
	["Feature.AppealsPortal.Label.TypePlural.AvatarAccessory"] = "avatar accessories",
	["Feature.AppealsPortal.Label.TypePlural.AvatarAccessoryText"] = "avatar accessory names and descriptions",
	["Feature.AppealsPortal.Label.TypePlural.Bundle"] = "bundles",
	["Feature.AppealsPortal.Label.TypePlural.BundleText"] = "bundle names and descriptions",
	["Feature.AppealsPortal.Label.TypePlural.Chat"] = "text chats",
	["Feature.AppealsPortal.Label.TypePlural.CommerceProduct"] = "commerce products",
	["Feature.AppealsPortal.Label.TypePlural.Experience"] = "experiences",
	["Feature.AppealsPortal.Label.TypePlural.Game"] = "Games",
	["Feature.AppealsPortal.Label.TypePlural.Image"] = "images",
	["Feature.AppealsPortal.Label.TypePlural.Look"] = "shared avatars",
	["Feature.AppealsPortal.Label.TypePlural.LookText"] = "shared avatar names and descriptions",
	["Feature.AppealsPortal.Label.TypePlural.Mesh"] = "meshes",
	["Feature.AppealsPortal.Label.TypePlural.Model"] = "models",
	["Feature.AppealsPortal.Label.TypePlural.Plugin"] = "plugins",
	["Feature.AppealsPortal.Label.TypePlural.Screenshot"] = "screenshots",
	["Feature.AppealsPortal.Label.TypePlural.Video"] = "videos",
	["Feature.AppealsPortal.Label.TypePlural.Voice"] = "voice chats",
	["Feature.AppealsPortal.Label.UploadTime"] = "Upload Time",
	["Feature.AppealsPortal.Label.Username"] = "Username",
	["Feature.AppealsPortal.Label.ViolativeExperienceDescription"] = "Violative Experience Description",
	["Feature.AppealsPortal.Label.ViolativeExperienceName"] = "Violative Experience Name",
	["Feature.NotApproved.Action.Continue"] = "Continue",
	["Feature.NotApproved.Action.LogOut"] = "Log out",
	["Feature.NotApproved.Action.Pending"] = "Pending",
	["Feature.NotApproved.Action.ReactivateAccount"] = "Re-activate My Account",
	["Feature.NotApproved.Action.ReportMistake"] = "Report a mistake",
	["Feature.NotApproved.Action.RuleConfirmation"] = "I agree to know and follow the rules.",
	["Feature.NotApproved.Action.UserAgree"] = "I Agree",
	["Feature.NotApproved.Action.ViewAppealGuidelines"] = "View appeal guidelines and disclosures",
	["Feature.NotApproved.Action.ViewLess"] = "View less",
	["Feature.NotApproved.Action.ViewMore"] = "View more",
	["Feature.NotApproved.Action.ViewRules"] = "View rules",
	["Feature.NotApproved.Action.ViewRulesUGCAvatarGuidelines"] = "View rules on UGC avatar guidelines",
	["Feature.NotApproved.Description.AppealViaSupport"] = "To appeal this decision, {link}contact support.{linkEnd}",
	["Feature.NotApproved.Description.AppealWithPortal"] = "To request an appeal visit {startLink}Violations & Appeals{endLink}.",
	["Feature.NotApproved.Description.AppealsProcess"] = "To learn more about the appeals process, visit {startLink}Appeal Your Content Moderation{endLink}.",
	["Feature.NotApproved.Description.AutomatedDetectionAutomatedDecision"] = "This policy violation was detected by automated means, and we used automation when making this decision",
	["Feature.NotApproved.Description.AutomatedDetectionAutomatedDecision.V2"] = "We used automated systems to detect this violation and make this decision.",
	["Feature.NotApproved.Description.AutomatedDetectionManualDecision"] = "This policy violation was detected by automated means",
	["Feature.NotApproved.Description.AutomatedDetectionManualDecision.V2"] = "We used automated systems to detect this violation.",
	["Feature.NotApproved.Description.AvatarBrokeRules"] = "Please change your avatar. Soon, players with avatars that break our Community Standards will be suspended from this game.",
	["Feature.NotApproved.Description.AvatarViolation"] = "THIS CAN BE DELETED",
	["Feature.NotApproved.Description.Ban"] = "Your account has been disabled. You may re-activate it after {date}.",
	["Feature.NotApproved.Description.Ban.V2"] = "Your account has been suspended due to your violation history. You may re-activate it after {date}.",
	["Feature.NotApproved.Description.BannedDescription.Kids"] = "You can’t use this account any more.",
	["Feature.NotApproved.Description.Behavior"] = "Your behavior",
	["Feature.NotApproved.Description.BrokeRulesBanned"] = "We banned your account because of repeated or serious rule-breaking.",
	["Feature.NotApproved.Description.BrokeRulesGeneric"] = "Your behavior broke the rules of our community.",
	["Feature.NotApproved.Description.BrokeRulesPolicy"] = "Your behavior broke the rules against {policy}.",
	["Feature.NotApproved.Description.BrokeRulesPolicy.V2"] = "Your behavior broke the rules against: {policy}.",
	["Feature.NotApproved.Description.BrokeRulesSpecific"] = "broke the rules against {policies}.",
	["Feature.NotApproved.Description.BrokeRulesType"] = "One of your {type} broke the rules of our community.",
	["Feature.NotApproved.Description.BrokeRulesTypePolicy"] = "One of your {type} broke the rules against {policy}.",
	["Feature.NotApproved.Description.BrokeRulesTypePolicy.V2"] = "One of your {type} broke the rules against: {policy}.",
	["Feature.NotApproved.Description.CommunityStandards"] = "Please abide by the {startLink}Roblox Community Standards{endLink} so that Roblox can be fun for users of all ages.",
	["Feature.NotApproved.Description.Delete"] = "Your account has been terminated.",
	["Feature.NotApproved.Description.FollowTheRules"] = "Make sure you know the rules and follow them.",
	["Feature.NotApproved.Description.Foreshadow"] = "We may give you a longer suspension —or even ban your account— if you keep breaking the rules.",
	["Feature.NotApproved.Description.Foreshadow.Kids"] = "If you break more rules, you may be suspended for longer. Or banned.",
	["Feature.NotApproved.Description.Foreshadow.V2"] = "We may give you a longer suspension —or even ban your account— if you keep breaking the rules.",
	["Feature.NotApproved.Description.LinkedAccounts"] = "Consequences are based on your behavior across all linked accounts.",
	["Feature.NotApproved.Description.ManualDetectionAutomatedDecision"] = "We used automation when making this decision",
	["Feature.NotApproved.Description.ManualDetectionAutomatedDecision.V2"] = "We used automated systems to make this decision.",
	["Feature.NotApproved.Description.Mistake"] = "You can appeal or ask us to review this decision here.",
	["Feature.NotApproved.Description.Mistake.Kids"] = "Did we make a mistake? You can appeal.",
	["Feature.NotApproved.Description.Mistake.V2"] = "Did we make a mistake? You can appeal or ask us to review this decision here.",
	["Feature.NotApproved.Description.Mistake.V3"] = "If you think that we’ve made a mistake, you can appeal this decision.",
	["Feature.NotApproved.Description.PluralViolation"] = "One of your {type}",
	["Feature.NotApproved.Description.ReactivationNotice"] = "Select ‘Continue’ to review our rules and you can play right after that.",
	["Feature.NotApproved.Description.ReviewProcess"] = "We review your activity using both technology and people.",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.Bullying.Kids"] = "Be kind — no picking on people. \nNo threats to hurt anyone. \nProtect people\'s private information.",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.MisuingRobloxSystems"] = "Pretending to be someone you’re not\nReporting users for things that didn’t happen\nLying to trick people into doing something\nTrying to get into other people’s accounts\nCreating a new Roblox account to get around rules that keep Roblox safe",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.MisusingRobloxSystems"] = "Pretending to be someone you’re not\nReporting users for things that didn’t happen\nLying to trick people into doing something\nTrying to get into other people’s accounts\nCreating a new Roblox account to get around rules that keep Roblox safe",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.PII"] = "Names, addresses, phone numbers, emails\nUsernames on other accounts \nPasswords",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.RealLifeEvents"] = "Violence that hurt many people or caused a lot of damage\nTerrible accidents or natural disasters such as earthquakes, hurricanes, and tornadoes\nShocking crimes in the news\nReal-life events where groups of people are treated cruelly or unfairly",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.SSHAndIllegalRegAct"] = "Ways to hurt yourself or others\nDangerous physical challenges including online trends in the real world\nThings that are illegal or dangerous such as alcohol and drugs\nGambling, betting or games of chance for prizes\nInstructions for making weapons in the real world",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.SexualContent.Kids"] = "We stay friends on Roblox.\nWe don\'t flirt, kiss, or date.\nOur avatars wear clothes that don’t show too much.",
	["Feature.NotApproved.Description.RuleExplanation.Bullets.SharingPII.Kids"] = "Passwords\nReal names, addresses, phone numbers, or emails\nUsernames for other accounts\nPhotos of people",
	["Feature.NotApproved.Description.RuleExplanation.BullyingHarassmentDiscrimination"] = "It’s never okay to say mean things to someone or about another person. This includes threatening to harm them, such as by sharing their private information or hurting them in real life. \nIt’s also against the rules to be mean to someone or exclude them because of who they are, what they believe, or where they come from.",
	["Feature.NotApproved.Description.RuleExplanation.Dating"] = "When you chat, keep it friendly and not flirty. Romantic behaviors like kissing or dating are not allowed. It’s also important that avatar clothes aren\'t too revealing.",
	["Feature.NotApproved.Description.RuleExplanation.DirectingUsersOffPlatform"] = "It\'s against the rules to share links in chat to other websites or tell people how to find your profile on other apps or social media. If someone tells you to go to another website, you shouldn\'t do it. Keep your conversations and gameplay on Roblox.\nIt\'s also not okay to buy, sell, or trade Robux or Roblox items outside of Roblox.",
	["Feature.NotApproved.Description.RuleExplanation.MisuingRobloxSystems"] = "It’s against the rules to cheat or lie or share ways to do that on Roblox. For example:",
	["Feature.NotApproved.Description.RuleExplanation.MisusingRobloxSystems"] = "It’s against the rules to cheat or lie or share ways to do that on Roblox. For example:",
	["Feature.NotApproved.Description.RuleExplanation.PII"] = "To keep everyone and their accounts safe, it’s against the rules to ask for or share private information, such as:",
	["Feature.NotApproved.Description.RuleExplanation.RealLifeEvents"] = "It’s against the rules to be disrespectful about specific moments that happened in the real world. This includes recreating or making fun of events or the people in them, especially when they’re sad or scary for a lot of people.\nThis includes:",
	["Feature.NotApproved.Description.RuleExplanation.SSHAndIllegalRegulatedActivities"] = "It’s never acceptable to create content, chat or joke about dangerous or harmful things, such as:",
	["Feature.NotApproved.Description.RuleExplanation.SharingPII.Kids"] = "Don\'t share:",
	["Feature.NotApproved.Description.RuleExplanation.Spam"] = "It’s never okay to keep messaging the same words over and over again.",
	["Feature.NotApproved.Description.RuleExplanation.Swearing"] = "It’s never OK to use swear words. This includes using misspellings, symbols, or other methods to try to get around detection systems.",
	["Feature.NotApproved.Description.RuleExplanation.ViolentContentAndGore"] = "It’s against the rules to show realistic violence or anything that makes it look like a person, animal or character is seriously physically or emotionally hurt.",
	["Feature.NotApproved.Description.RuleImportance.Bullets.SharingPII.Kids"] = "It can be hard to know who to trust online.\nStrangers can use your info to find you.\nSharing passwords lets people steal your account or your Robux.",
	["Feature.NotApproved.Description.RuleImportance.Bullying.Kids"] = "Being mean hurts other players. Kindness keeps Roblox fun for everyone.",
	["Feature.NotApproved.Description.RuleImportance.BullyingHarassmentDiscrimination"] = "To keep our community fun for everyone, we don’t use words or actions that make someone feel unsafe or uncomfortable. Roblox is for all races, ethnicities, gender identities, abilities, sexual orientations, and religions.",
	["Feature.NotApproved.Description.RuleImportance.Dating"] = "Keeping chats and avatars focused on friendships helps make sure everyone feels comfortable.",
	["Feature.NotApproved.Description.RuleImportance.DirectingUsersOffPlatform"] = "Roblox has safety protections to try to keep chats and interactions safe. Links can take you to fake websites that look just like Roblox to steal your account and items. The sites could also have pictures or videos that are inappropriate. If you trade Robux or items outside of Roblox, people can lie and not give you what they promised.",
	["Feature.NotApproved.Description.RuleImportance.MisuingRobloxSystems"] = "Roblox stays fun for everyone when we all follow rules and play honestly, so that no one has an unfair advantage.",
	["Feature.NotApproved.Description.RuleImportance.MisusingRobloxSystems"] = "Roblox stays fun for everyone when we all follow rules and play honestly, so that no one has an unfair advantage.",
	["Feature.NotApproved.Description.RuleImportance.PII"] = "If a stranger figures out who you are in real life, they can try to contact you outside of Roblox. This can be dangerous because it’s hard to know online if someone is good or bad. That’s why we also never share passwords. Someone can steal your account and everything you’ve earned.",
	["Feature.NotApproved.Description.RuleImportance.RealLifeEvents"] = "For someone who went through these things, seeing them recreated or joked about can be very upsetting.",
	["Feature.NotApproved.Description.RuleImportance.SSHAndIllegalRegulatedActivities"] = "Sharing content about hurting yourself or others isn’t safe. If you\'re having a tough time, it\'s important to talk to an adult that you trust. Things like sharing dangerous stunts can inspire others to try them and get seriously hurt. By not sharing this stuff, you\'re helping to keep yourself and everyone on Roblox safe.",
	["Feature.NotApproved.Description.RuleImportance.SexualContent.Kids"] = "Friendly chats and avatars make Roblox fun for everyone.",
	["Feature.NotApproved.Description.RuleImportance.Spam"] = "Spamming makes it hard to follow conversations and disrupts the fun.",
	["Feature.NotApproved.Description.RuleImportance.Swearing"] = "Roblox is for everyone, including young kids. We use words that are respectful and welcoming for our entire community.",
	["Feature.NotApproved.Description.RuleImportance.ViolentContentAndGore"] = "Our community includes young kids and seeing extreme violence can be scary and upsetting for them.",
	["Feature.NotApproved.Description.SecondChance.Details"] = "You can go back to playing now. You won’t be able to appeal this decision later.",
	["Feature.NotApproved.Description.SecondChance.Second"] = "You can avoid a suspension this one time because you’ve behaved responsibly in the past.",
	["Feature.NotApproved.Description.SuspendedUntil"] = "You\'re suspended until {date} at {time}.",
	["Feature.NotApproved.Description.Violation"] = "Our content monitors have determined that your behavior at Roblox has been in violation of our {startLink}Terms of Use{endLink}.",
	["Feature.NotApproved.Description.WarningDescription.Kids"] = "You broke a rule. You may get suspended if this goes on.",
	["Feature.NotApproved.Heading.AccountBanned"] = "Account Banned",
	["Feature.NotApproved.Heading.AccountDeleted"] = "Account Deleted",
	["Feature.NotApproved.Heading.AccountTerminated"] = "Account Terminated",
	["Feature.NotApproved.Heading.Banned"] = "Banned",
	["Feature.NotApproved.Heading.BannedMultipleDays"] = "Banned for {number} Days",
	["Feature.NotApproved.Heading.BannedMultipleHours"] = "Banned for {number} Hours",
	["Feature.NotApproved.Heading.BannedMultipleMinutes"] = "Banned for {number} Minutes",
	["Feature.NotApproved.Heading.BannedMultipleSeconds"] = "Banned for {number} Seconds",
	["Feature.NotApproved.Heading.BannedOneDayOnly"] = "Banned for 1 Day",
	["Feature.NotApproved.Heading.BannedOneHour"] = "Banned for 1 Hour",
	["Feature.NotApproved.Heading.BannedOneMinute"] = "Banned for 1 Minute",
	["Feature.NotApproved.Heading.BannedOneSecond"] = "Banned for 1 Second",
	["Feature.NotApproved.Heading.Error"] = "An unknown error occurred. Please try again later.",
	["Feature.NotApproved.Heading.ReactivationNotice"] = "Get back to playing",
	["Feature.NotApproved.Heading.RecentlyChecked"] = "What we checked recently",
	["Feature.NotApproved.Heading.RuleExplanation.Bullying.Kids"] = "Treat people with respect",
	["Feature.NotApproved.Heading.RuleExplanation.BullyingHarassmentDiscrimination"] = "Make everyone feel welcomed",
	["Feature.NotApproved.Heading.RuleExplanation.Dating"] = "Stay in the friend zone",
	["Feature.NotApproved.Heading.RuleExplanation.DirectingUsersOffPlatform"] = "Keep it on Roblox",
	["Feature.NotApproved.Heading.RuleExplanation.MisuingRobloxSystems"] = "Play fairly and honestly",
	["Feature.NotApproved.Heading.RuleExplanation.MisusingRobloxSystems"] = "Play fairly and honestly",
	["Feature.NotApproved.Heading.RuleExplanation.PII"] = "Guard private information",
	["Feature.NotApproved.Heading.RuleExplanation.RealLifeEvents"] = "Be considerate of real-life events",
	["Feature.NotApproved.Heading.RuleExplanation.SSHAndIllegalRegulatedActivities"] = "Keep minds and bodies healthy",
	["Feature.NotApproved.Heading.RuleExplanation.SexualContent.Kids"] = "Keep it friendly",
	["Feature.NotApproved.Heading.RuleExplanation.SharingPII.Kids"] = "Keep your info private",
	["Feature.NotApproved.Heading.RuleExplanation.Spam"] = "Let conversations flow",
	["Feature.NotApproved.Heading.RuleExplanation.Swearing"] = "Use kind and respectful words",
	["Feature.NotApproved.Heading.RuleExplanation.ViolentContentAndGore"] = "Keep calm and play on",
	["Feature.NotApproved.Heading.RuleImportance"] = "Why does this matter?",
	["Feature.NotApproved.Heading.RuleImportance.Kids"] = "Why this matters",
	["Feature.NotApproved.Heading.SecondChance"] = "Learn this rule, go back to playing right away",
	["Feature.NotApproved.Heading.SecondChance.Details"] = "Avoid a suspension this one time?",
	["Feature.NotApproved.Heading.Suspended"] = "Suspended",
	["Feature.NotApproved.Heading.Suspended14Days"] = "Suspended for 14 days",
	["Feature.NotApproved.Heading.Suspended1Year"] = "Suspended for 1 year",
	["Feature.NotApproved.Heading.SuspendedOneDay"] = "Suspended for 1 day",
	["Feature.NotApproved.Heading.SuspendedOneHour"] = "Suspended for 1 hour",
	["Feature.NotApproved.Heading.SuspendedSevenDays"] = "Suspended for 7 days",
	["Feature.NotApproved.Heading.SuspendedSixHours"] = "Suspended for 6 hours",
	["Feature.NotApproved.Heading.SuspendedSixMonths"] = "Suspended for 6 months",
	["Feature.NotApproved.Heading.SuspendedSixtyDays"] = "Suspended for 60 days",
	["Feature.NotApproved.Heading.SuspendedThirtyDays"] = "Suspended for 30 days",
	["Feature.NotApproved.Heading.SuspendedThreeDays"] = "Suspended for 3 days",
	["Feature.NotApproved.Heading.Warning"] = "Warning",
	["Feature.NotApproved.Heading.WhatNext"] = "What happens next",
	["Feature.NotApproved.Heading.Why"] = "Why?",
	["Feature.NotApproved.Label.AbuseType.AccountTheft"] = "Account Theft",
	["Feature.NotApproved.Label.AbuseType.AdultContent"] = "Adult Content",
	["Feature.NotApproved.Label.AbuseType.Advertisement"] = "Advertisement",
	["Feature.NotApproved.Label.AbuseType.Advertising"] = "Advertising",
	["Feature.NotApproved.Label.AbuseType.AgeInappropriateMetadata"] = "Age Inappropriate Metadata",
	["Feature.NotApproved.Label.AbuseType.AssetOwnership"] = "Asset Ownership",
	["Feature.NotApproved.Label.AbuseType.Billing"] = "Billing",
	["Feature.NotApproved.Label.AbuseType.BlockedContent"] = "BlockedContent",
	["Feature.NotApproved.Label.AbuseType.Bullying.Kids"] = "Bullying",
	["Feature.NotApproved.Label.AbuseType.Bullying.Note.Kids"] = "We found hurtful words in your activity.",
	["Feature.NotApproved.Label.AbuseType.Chargeback"] = "Chargeback",
	["Feature.NotApproved.Label.AbuseType.CheatandExploits"] = "Cheat and Exploits",
	["Feature.NotApproved.Label.AbuseType.ChildEndangerment"] = "Child Endangerment",
	["Feature.NotApproved.Label.AbuseType.ChildEndangerment.V2"] = "Child Exploitation",
	["Feature.NotApproved.Label.AbuseType.ChildEndangerment.V3"] = "Harmful Content/Behavior",
	["Feature.NotApproved.Label.AbuseType.ChildEndangerment.V4"] = "Child Safety",
	["Feature.NotApproved.Label.AbuseType.ClickbaitAds"] = "Clickbait Ads",
	["Feature.NotApproved.Label.AbuseType.Commerce"] = "Commerce",
	["Feature.NotApproved.Label.AbuseType.CompromisedAccount"] = "Compromised Account",
	["Feature.NotApproved.Label.AbuseType.ContestsandSweepstakes"] = "Contests and Sweepstakes",
	["Feature.NotApproved.Label.AbuseType.CopyrightDMCA"] = "Copyright/DMCA",
	["Feature.NotApproved.Label.AbuseType.DMCA"] = "DMCA",
	["Feature.NotApproved.Label.AbuseType.DMCAEarlyLegalStrike"] = "DMCA Early Legal Strike",
	["Feature.NotApproved.Label.AbuseType.DMCAFinalLegalStrike"] = "DMCA Final Legal Strike",
	["Feature.NotApproved.Label.AbuseType.Dating"] = "Dating",
	["Feature.NotApproved.Label.AbuseType.DatingImagery"] = "Dating Imagery",
	["Feature.NotApproved.Label.AbuseType.DatingandRomanticContent"] = "Dating and Romantic Content",
	["Feature.NotApproved.Label.AbuseType.Depressive"] = "Depressive",
	["Feature.NotApproved.Label.AbuseType.DerogatoryHarrassment"] = "Derogatory/Harassment",
	["Feature.NotApproved.Label.AbuseType.DirectingUsersOffPlatform"] = "Directing Users Off-Platform",
	["Feature.NotApproved.Label.AbuseType.DirectingUsersOffPlatform.V2"] = "Directing Users Off-Platform",
	["Feature.NotApproved.Label.AbuseType.Discriminatory"] = "Discriminatory",
	["Feature.NotApproved.Label.AbuseType.DiscriminatoryContent"] = "Discriminatory Content",
	["Feature.NotApproved.Label.AbuseType.DiscriminatoryorNaziContent"] = "Discriminatory or Nazi Content",
	["Feature.NotApproved.Label.AbuseType.DisruptiveAudio"] = "Disruptive Audio",
	["Feature.NotApproved.Label.AbuseType.DistortedAudio"] = "Distorted Audio",
	["Feature.NotApproved.Label.AbuseType.DrugandAlcoholReferences"] = "Drug and Alcohol References",
	["Feature.NotApproved.Label.AbuseType.DrugsAlcohol"] = "Drugs, Alcohol",
	["Feature.NotApproved.Label.AbuseType.EncouragingDangerousBehavior"] = "Encouraging Dangerous Behavior",
	["Feature.NotApproved.Label.AbuseType.ExplicitNudityPorn"] = "Explicit Nudity/Porn",
	["Feature.NotApproved.Label.AbuseType.ExplicitSexualReferencesandInnuendo"] = "Explicit Sexual References and Innuendo",
	["Feature.NotApproved.Label.AbuseType.Exploiting"] = "Exploiting",
	["Feature.NotApproved.Label.AbuseType.ExtortionandBlackmail"] = "Extortion and Blackmail",
	["Feature.NotApproved.Label.AbuseType.GangImages"] = "Gang Images",
	["Feature.NotApproved.Label.AbuseType.Grooming"] = "Grooming",
	["Feature.NotApproved.Label.AbuseType.Harassment"] = "Harassment",
	["Feature.NotApproved.Label.AbuseType.HiddenMessageClothing"] = "Hidden Message Clothing",
	["Feature.NotApproved.Label.AbuseType.IllegalandRegulatedContent"] = "Illegal and Regulated Content",
	["Feature.NotApproved.Label.AbuseType.IllicitSubstance"] = "Illicit Substance",
	["Feature.NotApproved.Label.AbuseType.Impersonation"] = "Impersonation",
	["Feature.NotApproved.Label.AbuseType.Inappropriate"] = "Inappropriate",
	["Feature.NotApproved.Label.AbuseType.InappropriateContent"] = "Inappropriate Content",
	["Feature.NotApproved.Label.AbuseType.IpViolation"] = "Intellectual Property Violation",
	["Feature.NotApproved.Label.AbuseType.IrlDangerousActivities"] = "IRL Dangerous Activities",
	["Feature.NotApproved.Label.AbuseType.LoudEarbleeders"] = "Loud Earbleeders",
	["Feature.NotApproved.Label.AbuseType.Malicious"] = "Malicious",
	["Feature.NotApproved.Label.AbuseType.MinorSwearing"] = "Minor Swearing",
	["Feature.NotApproved.Label.AbuseType.Misleading"] = "Misleading",
	["Feature.NotApproved.Label.AbuseType.MisusingRobloxSystems"] = "Misusing Roblox Systems",
	["Feature.NotApproved.Label.AbuseType.Nazis"] = "Nazis",
	["Feature.NotApproved.Label.AbuseType.None"] = "None",
	["Feature.NotApproved.Label.AbuseType.NoneoftheAbove"] = "None of the Above",
	["Feature.NotApproved.Label.AbuseType.NotRelatedtoRoblox"] = "Not Related to Roblox",
	["Feature.NotApproved.Label.AbuseType.OffPlatformSpeechandBehavior"] = "Off Platform Speech and Behavior",
	["Feature.NotApproved.Label.AbuseType.OffSiteLinks"] = "Off-Site Links",
	["Feature.NotApproved.Label.AbuseType.Other"] = "Other",
	["Feature.NotApproved.Label.AbuseType.PersonalAttackHarassmentBullying"] = "Personal Attack/Harassment/Bullying",
	["Feature.NotApproved.Label.AbuseType.PhishingScam"] = "Phishing/Scam",
	["Feature.NotApproved.Label.AbuseType.PlayersScreamingintoMicrophone"] = "Players Screaming into Microphone",
	["Feature.NotApproved.Label.AbuseType.PoliticalContent"] = "Political Content",
	["Feature.NotApproved.Label.AbuseType.PoliticalContent.V2"] = "Political Figures and Entities",
	["Feature.NotApproved.Label.AbuseType.Politics"] = "Politics",
	["Feature.NotApproved.Label.AbuseType.PornographicSounds"] = "Pornographic Sounds",
	["Feature.NotApproved.Label.AbuseType.Privacy"] = "Privacy",
	["Feature.NotApproved.Label.AbuseType.PrivacyAskingforPII"] = "Privacy: Asking for PII",
	["Feature.NotApproved.Label.AbuseType.PrivacyGivingPII"] = "Privacy: Giving PII",
	["Feature.NotApproved.Label.AbuseType.Profanity"] = "Profanity",
	["Feature.NotApproved.Label.AbuseType.RMT"] = "RMT",
	["Feature.NotApproved.Label.AbuseType.RealInfo"] = "Real Info",
	["Feature.NotApproved.Label.AbuseType.RealLifeThreats"] = "Real-Life Threats",
	["Feature.NotApproved.Label.AbuseType.RealLifeTragedy"] = "Real-Life Tragedy",
	["Feature.NotApproved.Label.AbuseType.RealLifeTragedy.V2"] = "Real-World Sensitive Events",
	["Feature.NotApproved.Label.AbuseType.RedArmbandsNotNazis"] = "Red Armbands (Not Nazis)",
	["Feature.NotApproved.Label.AbuseType.RobloxEconomy"] = "Roblox Economy",
	["Feature.NotApproved.Label.AbuseType.Scamming"] = "Scamming",
	["Feature.NotApproved.Label.AbuseType.SeekingSexualContent"] = "Seeking Sexual Content",
	["Feature.NotApproved.Label.AbuseType.SexualAdultContent"] = "Sexual/Adult Content",
	["Feature.NotApproved.Label.AbuseType.SexualContent"] = "Sexual Content",
	["Feature.NotApproved.Label.AbuseType.SexualContent.Kids"] = "Adult content",
	["Feature.NotApproved.Label.AbuseType.SexualContent.Note.Kids"] = "We found words or pictures that are not okay for kids. Things like naked photos or romance.",
	["Feature.NotApproved.Label.AbuseType.SharingPII.Kids"] = "Sharing private information",
	["Feature.NotApproved.Label.AbuseType.SharingPII.Note.Kids"] = "We found things like a real name, phone number, or photos of real people.",
	["Feature.NotApproved.Label.AbuseType.Shock"] = "Shock",
	["Feature.NotApproved.Label.AbuseType.Spam"] = "Spam",
	["Feature.NotApproved.Label.AbuseType.SuggestiveSexualizedImagery"] = "Suggestive/Sexualized Imagery",
	["Feature.NotApproved.Label.AbuseType.SuicideSelfHarm"] = "Suicide/Self-Harm",
	["Feature.NotApproved.Label.AbuseType.Swearing"] = "Swearing",
	["Feature.NotApproved.Label.AbuseType.TerrorismExtremism"] = "Terrorism/Extremism",
	["Feature.NotApproved.Label.AbuseType.TextFilterProfanity"] = "Text Filter / Profanity",
	["Feature.NotApproved.Label.AbuseType.Threats"] = "Threats",
	["Feature.NotApproved.Label.AbuseType.ThreatsOrAbuseOfRobloxEmployeesOrAffiliates"] = "Threats or Abuse of Roblox Employees or Affiliates",
	["Feature.NotApproved.Label.AbuseType.Trademark"] = "Trademark Violation",
	["Feature.NotApproved.Label.AbuseType.UnclassifiedMild"] = "Unclassified Mild",
	["Feature.NotApproved.Label.AbuseType.ViolentContentAndGore"] = "Violent Content and Gore",
	["Feature.NotApproved.Label.AbuseType.VirtualCasino"] = "Virtual Casino",
	["Feature.NotApproved.Label.AbuseType.VirtualCasino.Note"] = "Roblox does not permit using third-parties to buy, sell, or trade Robux, promotional codes that falsely appear to be from Roblox Corporation, or inappropriate use of the community payout system.",
	["Feature.NotApproved.Label.ChargebackNextSteps"] = "What do I do next?",
	["Feature.NotApproved.Label.CommunityStandards"] = "Community Standards",
	["Feature.NotApproved.Label.ConsoleDeviceNoticeUA"] = "Please sign in to Roblox.com on a separate device to begin reactivating your account.",
	["Feature.NotApproved.Label.Days"] = "{number} days",
	["Feature.NotApproved.Label.Decision"] = "Decision",
	["Feature.NotApproved.Label.DecisionMethod"] = "Decision method",
	["Feature.NotApproved.Label.DecisionMethod.V2"] = "How we reviewed this",
	["Feature.NotApproved.Label.EmailReactivationNoticeUA"] = "Please verify your email address to re-activate this account. ",
	["Feature.NotApproved.Label.EmailVerificationButtonText"] = "Verify Email",
	["Feature.NotApproved.Label.EmailVerificationNotice"] = "Your account was suspended for unauthorized charges. You must verify your email address to unlock your account.",
	["Feature.NotApproved.Label.Evidence.VoiceRecording"] = "Voice chat conversation on {date} at {time} in {experienceName}",
	["Feature.NotApproved.Label.ExploitDetected"] = "Exploit detected",
	["Feature.NotApproved.Label.Hours"] = "{hours}:{minutes} hours",
	["Feature.NotApproved.Label.LatestActivity"] = "Latest activity we reviewed",
	["Feature.NotApproved.Label.LoadingImage"] = "Loading image",
	["Feature.NotApproved.Label.LogoutProgress"] = "Logout in progress",
	["Feature.NotApproved.Label.MenuContent"] = "Menu content",
	["Feature.NotApproved.Label.MessageToUser.AltConsequence.V2"] = "This account is linked to an account banned for a severe violation of our Community Standards. The violation can be appealed using the banned account.",
	["Feature.NotApproved.Label.MessageToUser.AltConsequence.V3"] = "This account is linked to an account (@{account}) banned for a severe violation of our Community Standards. Only the banned account can appeal that violation. \n\nIf the two accounts shouldn\'t be linked to each other, send an appeal using this account from Violations & Appeals.",
	["Feature.NotApproved.Label.Mistake"] = "Did we make a mistake?",
	["Feature.NotApproved.Label.ModeratorMessage"] = " Moderator Note",
	["Feature.NotApproved.Label.ModeratorNote"] = "Moderator note",
	["Feature.NotApproved.Label.OffensiveItem"] = "Offensive Item",
	["Feature.NotApproved.Label.OffensiveItem.V2"] = "Offensive item",
	["Feature.NotApproved.Label.OpenMenu"] = "Open menu",
	["Feature.NotApproved.Label.PageProgress"] = "Page progress bar",
	["Feature.NotApproved.Label.ParentReactivationNoticeUA"] = "Your parent or legal guardian must help you re-activate this account.",
	["Feature.NotApproved.Label.ParentVerificationButtonText"] = "Ask my parent",
	["Feature.NotApproved.Label.ParentVerificationNotice"] = "Your account was suspended for unauthorized charges. Your parent or guardian must agree to unlock your account and will then be able to approve certain actions on Roblox for you.",
	["Feature.NotApproved.Label.Reason"] = "Reason",
	["Feature.NotApproved.Label.RecentViolation"] = "Recent Violation",
	["Feature.NotApproved.Label.ReviewDate"] = "Review date",
	["Feature.NotApproved.Label.Reviewed"] = "Reviewed",
	["Feature.NotApproved.Label.RuleAcknowledgment"] = "Check to confirm you understand.",
	["Feature.NotApproved.Label.RuleBreakingAddsUp"] = "Rule-breaking adds up",
	["Feature.NotApproved.Label.RuleExplanation.Acknowledgement"] = "I understand this rule",
	["Feature.NotApproved.Label.RuleImportance.Acknowledgement"] = "Check to confirm you understand.",
	["Feature.NotApproved.Label.RuleViolationsAddUp"] = "Rule violations add up",
	["Feature.NotApproved.Label.Sublabel.AccountUsernameOrDisplayNameReset"] = "Inappropriate username or display name",
	["Feature.NotApproved.Label.Sublabel.AdvertisingAdFraud"] = "Ad Fraud",
	["Feature.NotApproved.Label.Sublabel.AdvertisingAdTransparency"] = "Ad Transparency",
	["Feature.NotApproved.Label.Sublabel.AdvertisingAdTransparencyAdsDisclosure"] = "Ads Disclosure",
	["Feature.NotApproved.Label.Sublabel.AdvertisingAgeInappropriateContent"] = "Age-Inappropriate Content",
	["Feature.NotApproved.Label.Sublabel.AdvertisingBodyAlterations"] = "Body Alterations",
	["Feature.NotApproved.Label.Sublabel.AdvertisingCharitableCauses"] = "Charitable Causes",
	["Feature.NotApproved.Label.Sublabel.AdvertisingClothingUndergarmentsRestricted"] = "Clothing Undergarments/Swimwear - Restricted",
	["Feature.NotApproved.Label.Sublabel.AdvertisingClothingUndergarmentsSports"] = "Undergarments/Swimwear - Sports",
	["Feature.NotApproved.Label.Sublabel.AdvertisingCryptocurrenciesAndNfts"] = "Cryptocurrencies and NFTs",
	["Feature.NotApproved.Label.Sublabel.AdvertisingDirectingOffPlatformGeneral"] = "Directing Users Off Platform",
	["Feature.NotApproved.Label.Sublabel.AdvertisingDirectingOffPlatformPermittedUrls"] = "Directing Users Off Platform - Permitted",
	["Feature.NotApproved.Label.Sublabel.AdvertisingDirectingUsersOffPlatform"] = "Directing Users Off-Platform",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEconomicOpportunity"] = "Economic Opportunity",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEconomicOpportunityNetworking"] = "Economic Opportunity - Networking and Job Search",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentFilmTvAdult"] = "Entertainment Film/TV - Adult",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentFilmTvTeens"] = "Entertainment Film/TV - Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentFilmTvYoungTeens"] = "Entertainment Film/TV - Young Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentGamingAdult"] = "Entertainment Gaming - Adult",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentGamingTeens"] = "Entertainment Gaming - Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingEntertainmentGamingYoungTeens"] = "Entertainment Gaming - Young Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFinancialServices"] = "Financial Services",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFinancialServicesAdults"] = "Financial Services - Adults",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFinancialServicesOther"] = "Financial Services - Other",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFinancialServicesTeens"] = "Financial Services - Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFoodAndBeverageFoodAndBeverages"] = "Food and Beverage - Other",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFoodAndBeverageHfssFoods"] = "Food and Beverage - HFSS",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFoodAndBeverageInfantFoods"] = "Infant Foods",
	["Feature.NotApproved.Label.Sublabel.AdvertisingFuneralServices"] = "Funeral Services",
	["Feature.NotApproved.Label.Sublabel.AdvertisingHighRiskSports"] = "High-risk Sports",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalAndRegulatedGoods"] = "Illegal and Regulated Goods",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalBodyAlterations"] = "Body Alterations",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalCosmetics"] = "Regulated Goods - Cosmetics",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalCounterfeitingAndPiracy"] = "Counterfeiting and Piracy",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalHealthDietAndMedical"] = "Health, Diet, and Medical",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalKitchenKnives"] = "Regulated Goods - Kitchen Knives",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalMedicalDevices"] = "Regulated Goods - Medical Devices",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalOtcPharmaceuticals"] = "Regulated Goods - OTC Pharmaceuticals",
	["Feature.NotApproved.Label.Sublabel.AdvertisingIllegalOther"] = "Regulated Goods - Other",
	["Feature.NotApproved.Label.Sublabel.AdvertisingInvestigativeAndLegalServices"] = "Investigative and Legal Services",
	["Feature.NotApproved.Label.Sublabel.AdvertisingMaliciousSoftware"] = "Malicious Software",
	["Feature.NotApproved.Label.Sublabel.AdvertisingMartialArts"] = "Martial Arts",
	["Feature.NotApproved.Label.Sublabel.AdvertisingMatureMedia"] = "Mature Media",
	["Feature.NotApproved.Label.Sublabel.AdvertisingMisleadingReward"] = "Misleading Reward",
	["Feature.NotApproved.Label.Sublabel.AdvertisingMultiLevelMarketing"] = "Multi-Level Marketing",
	["Feature.NotApproved.Label.Sublabel.AdvertisingNoReward"] = "No Reward",
	["Feature.NotApproved.Label.Sublabel.AdvertisingOnlineServicesLiveAi"] = "Online Services - Live AI",
	["Feature.NotApproved.Label.Sublabel.AdvertisingOnlineServicesSocialCommerce"] = "Online Services - Social Commerce",
	["Feature.NotApproved.Label.Sublabel.AdvertisingParanormalAstrologicalAndOccult"] = "Paranormal, Astrological, and Occult",
	["Feature.NotApproved.Label.Sublabel.AdvertisingPolitics"] = "Politics",
	["Feature.NotApproved.Label.Sublabel.AdvertisingReligion"] = "Religion",
	["Feature.NotApproved.Label.Sublabel.AdvertisingToysHobbyAndLearning"] = "Toys, Hobby, and Learning",
	["Feature.NotApproved.Label.Sublabel.AdvertisingToysHobbyAndLearningAdults"] = "Toys, Hobby, Learning - Adults",
	["Feature.NotApproved.Label.Sublabel.AdvertisingToysHobbyAndLearningOther"] = "Toys, Hobby, Learning - Other",
	["Feature.NotApproved.Label.Sublabel.AdvertisingToysHobbyAndLearningTeens"] = "Toys, Hobby, Learning - Teens",
	["Feature.NotApproved.Label.Sublabel.AdvertisingTravelAndEvents"] = "Travel and Events",
	["Feature.NotApproved.Label.Sublabel.AdvertisingUnauthorizedAdvertising"] = "Unauthorized Advertising",
	["Feature.NotApproved.Label.Sublabel.AdvertisingUnrequestedAd"] = "Unrequested Ad",
	["Feature.NotApproved.Label.Sublabel.CommerceAdultSexualProducts"] = "Adult Sexual Products",
	["Feature.NotApproved.Label.Sublabel.CommerceAlcoholAndAlcoholRelatedProducts"] = "Alcohol and Alcohol-Related Products",
	["Feature.NotApproved.Label.Sublabel.CommerceAnimalsPlantsAndRelatedProducts"] = "Animals, Plants, and Related Products",
	["Feature.NotApproved.Label.Sublabel.CommerceAutomotiveProducts"] = "Automotive Products",
	["Feature.NotApproved.Label.Sublabel.CommerceBabyPregnancyAndChildcareProducts"] = "Baby, Pregnancy, and Childcare Products",
	["Feature.NotApproved.Label.Sublabel.CommerceBeautyAndPersonalCare"] = "Beauty and Personal Care",
	["Feature.NotApproved.Label.Sublabel.CommerceDigitalProducts"] = "Digital Products",
	["Feature.NotApproved.Label.Sublabel.CommerceDocumentsFinancialInstrumentsAndEconomicOpportunity"] = "Documents, Financial Instruments, and Economic Opportunity",
	["Feature.NotApproved.Label.Sublabel.CommerceElectronics"] = "Electronics",
	["Feature.NotApproved.Label.Sublabel.CommerceEvents"] = "Events",
	["Feature.NotApproved.Label.Sublabel.CommerceFoodAndBeverages"] = "Food and Beverages",
	["Feature.NotApproved.Label.Sublabel.CommerceGambling"] = "Gambling",
	["Feature.NotApproved.Label.Sublabel.CommerceGiftsCardsorDiscountCards"] = "Gifts Cards or Discount Cards",
	["Feature.NotApproved.Label.Sublabel.CommerceHazardousMaterial"] = "Hazardous Material",
	["Feature.NotApproved.Label.Sublabel.CommerceHealthcare"] = "Healthcare",
	["Feature.NotApproved.Label.Sublabel.CommerceHumanBodyPartsFluidsAndRelatedProducts"] = "Human Body Parts, Fluids, and Related Products",
	["Feature.NotApproved.Label.Sublabel.CommerceIllegalProductsAndServices"] = "Illegal Products and Services",
	["Feature.NotApproved.Label.Sublabel.CommerceInsufficientProductDescription"] = "Insufficient Product Description",
	["Feature.NotApproved.Label.Sublabel.CommerceMisleadingBundledDigitalItem"] = "Misleading Bundled Digital Item",
	["Feature.NotApproved.Label.Sublabel.CommerceNoBundledDigitalItem"] = "No Bundled Digital Item",
	["Feature.NotApproved.Label.Sublabel.CommercePreOrder"] = "Pre-Order",
	["Feature.NotApproved.Label.Sublabel.CommercePreOwnedRecalledProducts"] = "Pre-Owned / Recalled Products",
	["Feature.NotApproved.Label.Sublabel.CommerceSellerIntegrityViolation"] = "Seller Integrity Violation",
	["Feature.NotApproved.Label.Sublabel.CommerceServices"] = "Services",
	["Feature.NotApproved.Label.Sublabel.CommerceTobaccoAndEntheogens"] = "Tobacco and Entheogens",
	["Feature.NotApproved.Label.Sublabel.CommerceToysAndGames"] = "Toys and Games",
	["Feature.NotApproved.Label.Sublabel.CommerceWeaponsFirearmsAndRelatedProducts"] = "Weapons, Firearms, and Related Products",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityMissingDescriptor"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityMissingModeratePlusDescriptor"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityMissingSensitiveDescriptor"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityMissingUnplayableDescriptor"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityOffByMoreThanOneBucket"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.ContentMaturityOffByOneBucket"] = "Inaccurate Maturity & Compliance Questionnaire submission",
	["Feature.NotApproved.Label.Sublabel.EconomicOpportunity"] = "Economic Opportunity",
	["Feature.NotApproved.Label.Sublabel.Emissive"] = "Emissive",
	["Feature.NotApproved.Label.Sublabel.ExperienceSpam"] = "Publishing Spam",
	["Feature.NotApproved.Label.Sublabel.FraudAbuseOfTheAffiliateSystem"] = "Abuse of the Affiliate System",
	["Feature.NotApproved.Label.Sublabel.FraudAttemptedUnauthorizedPaymentMethodUse"] = "Attempted Unauthorized Payment Method Use",
	["Feature.NotApproved.Label.Sublabel.FraudPaymentAbuse"] = "Payment Abuse",
	["Feature.NotApproved.Label.Sublabel.FraudRepeatedRefundRequests"] = "Repeated Refund Requests",
	["Feature.NotApproved.Label.Sublabel.FraudSuspiciousAccountPatterns"] = "Suspicious Account Patterns",
	["Feature.NotApproved.Label.Sublabel.FraudSuspiciousRefundRequests"] = "Suspicious Refund Requests",
	["Feature.NotApproved.Label.Sublabel.FraudUnauthorizedPurchase"] = "Unauthorized Purchase",
	["Feature.NotApproved.Label.Sublabel.FraudUseOfUnauthorizedOffPlatformTransactions"] = "Use of Unauthorized Off-Platform Transactions for Roblox Content",
	["Feature.NotApproved.Label.Sublabel.FraudUseOfUnauthorizedPaymentMethod"] = "Use of Unauthorized Payment Method",
	["Feature.NotApproved.Label.Sublabel.FraudVirtualEconomyAbuse"] = "Virtual Economy Abuse",
	["Feature.NotApproved.Label.Sublabel.RealLifeEvents"] = "Real-life events",
	["Feature.NotApproved.Label.Sublabel.RomanceOrSex"] = "Romance or sex",
	["Feature.NotApproved.Label.Sublabel.TextScrubbed"] = "inappropriate experience name or description",
	["Feature.NotApproved.Label.Sublabel.TextScrubbed.Note"] = "Your experience name or experience description was found to be inappropriate. Both have been changed to a placeholder. You can create a new name and description in Creator Hub or Studio.",
	["Feature.NotApproved.Label.Sublabel.UGCBundleAccessories"] = "Accessories (hair, tails, extra limbs, etc.)",
	["Feature.NotApproved.Label.Sublabel.UGCBundleBakedInAssets"] = "Baked-In Assets",
	["Feature.NotApproved.Label.Sublabel.UGCBundleClothing"] = "Clothing",
	["Feature.NotApproved.Label.Sublabel.UGCBundleHead"] = "Head Doesn\'t Animate",
	["Feature.NotApproved.Label.Sublabel.UGCBundleInvisible"] = "Invisible Body Parts",
	["Feature.NotApproved.Label.Sublabel.UGCBundleMakeup"] = "Makeup",
	["Feature.NotApproved.Label.Sublabel.UGCBundleTattoos"] = "Tattoos",
	["Feature.NotApproved.Label.Sublabel.UGCDuplicate"] = "Duplicate Content",
	["Feature.NotApproved.Label.Sublabel.UGCMiscategorization"] = "Miscategorization",
	["Feature.NotApproved.Label.Sublabel.UGCSpam"] = "Spam",
	["Feature.NotApproved.Label.Suspension"] = "Suspension",
	["Feature.NotApproved.Label.Violation"] = "Violation",
	["Feature.NotApproved.Label.WhatHappened"] = "What happened",
	["Feature.NotApproved.SubHeading.RuleExplanation.BullyingHarassmentDiscrimination"] = "No bullying or discrimination",
	["Feature.NotApproved.SubHeading.RuleExplanation.Dating"] = "No romance or dating",
	["Feature.NotApproved.SubHeading.RuleExplanation.DirectingUsersOffPlatform"] = "No sharing links or trading off of Roblox",
	["Feature.NotApproved.SubHeading.RuleExplanation.MisuingRobloxSystems"] = "No cheating, lying or tricking",
	["Feature.NotApproved.SubHeading.RuleExplanation.MisusingRobloxSystems"] = "No cheating, lying or tricking",
	["Feature.NotApproved.SubHeading.RuleExplanation.PII"] = "Don\'t share contact or account info",
	["Feature.NotApproved.SubHeading.RuleExplanation.RealLifeEvents"] = "No recreating or making fun of upsetting moments",
	["Feature.NotApproved.SubHeading.RuleExplanation.SSHAndIllegalRegulatedActivities"] = "No dangerous or harmful behaviors",
	["Feature.NotApproved.SubHeading.RuleExplanation.Spam"] = "Spamming\'s against the rules",
	["Feature.NotApproved.SubHeading.RuleExplanation.Swearing"] = "No swearing",
	["Feature.NotApproved.SubHeading.RuleExplanation.ViolentContentAndGore"] = "No extreme violence",
	["Feature.NotApproved.Title.AvatarBrokeRules"] = "Your avatar broke the rules",
	["Feature.SafetyDashboard.Heading.AccountStatus.V2"] = "Account status, violations, and appeals",
	["Feature.SafetyDashboard.Heading.ReportHistory"] = "Report history",
}

-- helpers for engine calls the modules make -------------------------------------
local function __DefineFastFlag(name, default)
	local ok, v = pcall(function() return game:DefineFastFlag(name, default) end)
	if ok and v ~= nil then return v end
	return default
end
local function __DefineFastInt(name, default)
	local ok, v = pcall(function() return game:DefineFastInt(name, default) end)
	if ok and v ~= nil then return v end
	return default
end
local function __DefineFastString(name, default)
	local ok, v = pcall(function() return game:DefineFastString(name, default) end)
	if ok and v ~= nil then return v end
	return default
end
local function __GetEngineFeature(name)
	local ok, v = pcall(function() return game:GetEngineFeature(name) end)
	return ok and v or false
end

-- shim building blocks --------------------------------------------------------------
local function keyProxy() -- Enum-like table: every key maps to its own name
	return setmetatable({}, { __index = function(_, k) return k end })
end
local function noopProxy() -- every key is a no-op function
	return setmetatable({}, { __index = function() return function() end end })
end
local function thunk() return function() end end
local offline = function() return Promise.reject("offline preview") end
local OFFLINE_SERVICE = setmetatable({}, {
	__call = offline,
	__index = function() return offline end,
})

local LOCALE_KEY = newproxy and newproxy(false) or {}
local function format(key, params)
	local s = EN[key] or key
	if params then
		s = s:gsub("{(%w+)}", function(p)
			local v = params[p]
			if v ~= nil then return tostring(v) end
			return nil
		end)
	end
	return s
end
local function localizeMap(map)
	local out = { [LOCALE_KEY] = "en-us" }
	for name, k in pairs(map) do
		if type(k) == "table" then
			out[name] = format(k[1], k)
		else
			out[name] = format(k)
		end
	end
	return out
end

local FLAG_OVERRIDES = {
	FFlagKidsNotApprovedPageTreatment = false, -- adult page, like the screenshot
	FFlagNotApprovedPageIXPExposure = false,   -- no experiment exposure logging
	FFlagSignalsNavP3Dispatch = false,
	FFlagUseSignalsForModeration = false,
}
local SharedFlags = setmetatable({}, {
	__index = function(_, k)
		if FLAG_OVERRIDES[k] ~= nil then return FLAG_OVERRIDES[k] end
		if SharedFlagsReal then
			local ok, v = pcall(function() return SharedFlagsReal[k] end)
			if ok and v ~= nil then return v end
		end
		if type(k) == "string" and k:sub(1, 3) == "Get" then return function() return false end end
		if type(k) == "string" and k:sub(1, 7) == "FString" then return "" end
		return false
	end,
})

local closePreview -- set at mount time

-- theme lookup, same order as the Roblox app: device-level theme -> account theme -> light
local function themeFromValue(value)
	if typeof(value) == "EnumItem" then value = value.Name end
	if type(value) ~= "string" then return nil end
	local v = value:lower()
	if v == "dark" or v == "systemdark" then return "Dark" end
	if v == "light" or v == "systemlight" then return "Light" end
	if v == "system" then return "System" end
	return nil
end
local function systemTheme()
	local ok, value = pcall(function()
		local service = game:GetService("SystemThemeService")
		local okSync, v = pcall(function() return service:getSystemTheme() end)
		if okSync and v ~= nil then return v end
		return service:getSystemThemeAsync()
	end)
	local mode = ok and themeFromValue(value) or nil
	if mode == "System" then mode = nil end
	return mode
end
local function detectColorMode()
	local storage
	pcall(function() storage = game:GetService("AppStorageService") end)
	local userId = Players.LocalPlayer and tostring(Players.LocalPlayer.UserId) or ""

	local function resolve(mode, source)
		if mode == "System" then
			local sys = systemTheme()
			log("theme:", source, "= system ->", tostring(sys or "unknown, using Light"))
			return sys or "Light"
		end
		log("theme:", source, "=", mode)
		return mode
	end

	if storage then
		local okD, raw = pcall(function() return storage:GetItem("DeviceLevelTheme") end)
		if okD and type(raw) == "string" and raw ~= "" then
			local okJ, map = pcall(function() return HttpService:JSONDecode(raw) end)
			local mode = okJ and type(map) == "table" and themeFromValue(map[userId]) or nil
			if mode then return resolve(mode, "DeviceLevelTheme") end
		end
		local okA, account = pcall(function() return storage:GetItem("AuthenticatedTheme") end)
		local mode = okA and themeFromValue(account) or nil
		if mode then return resolve(mode, "AuthenticatedTheme") end
	else
		log("theme: AppStorageService unavailable")
	end
	log("theme: no saved setting, using Light (app default)")
	return "Light"
end

-- links open the same Roblox pages the app opens (web window, falling back to the in-game browser)
local LINK_METHODS = {
	{ "WebViewService:OpenWindow", function(url, title) game:GetService("WebViewService"):OpenWindow(url, title or "", true) end },
	{ "GuiService:OpenBrowserWindow", function(url) game:GetService("GuiService"):OpenBrowserWindow(url) end },
	{ "LinkingService:OpenUrl", function(url) game:GetService("LinkingService"):OpenUrl(url) end },
	{ "GuiService:OpenNativeOverlay", function(url, title) game:GetService("GuiService"):OpenNativeOverlay(title or "", url) end },
}
local workingMethod -- remembered once one succeeds
local function openWeb(url, title)
	log("open link:", url)
	if type(url) ~= "string" or url == "" then return end
	if workingMethod then
		local ok, e = pcall(workingMethod[2], url, title)
		if ok then return end
		log("  " .. workingMethod[1] .. " stopped working:", e)
	end
	for _, m in ipairs(LINK_METHODS) do
		local ok, e = pcall(m[2], url, title)
		if ok then
			log("  opened with " .. m[1])
			workingMethod = m
			return
		end
		log("  " .. m[1] .. " failed:", e)
	end
	log("  no method could open the link")
end
local function NavigateDown(page) return { type = "NavigateDown", page = page } end
local function dispatch(action)
	if type(action) == "table" and action.type == "NavigateDown" and type(action.page) == "table" then
		local page = action.page
		if page.name == "GenericWebPage" then
			openWeb(page.detail, page.extraProps and page.extraProps.title)
			return
		end
		log("navigation ignored:", tostring(page.name))
	end
end

-- Foundation with click logging on buttons (diagnostics only, behavior unchanged)
local FoundationShim = setmetatable({}, { __index = Foundation })
local function logActivations(Component, kind)
	return function(props)
		local p = table.clone(props)
		local original = props.onActivated
		p.onActivated = function(...)
			log("activated:", kind, tostring(props.text or props.testId or props.icon or ""))
			if original then return original(...) end
		end
		return React.createElement(Component, p, props.children)
	end
end
FoundationShim.Button = logActivations(Foundation.Button, "Button")
FoundationShim.IconButton = logActivations(Foundation.IconButton, "IconButton")

-- module system -------------------------------------------------------------------
local u2 = {}
local cache = {}
local NIL = {}
function u2.loadModule(id)
	local c = cache[id]
	if c ~= nil then
		if c == NIL then return nil end
		return c
	end
	local f = rawget(u2, id)
	if type(f) ~= "function" then error("port: missing module " .. tostring(id), 2) end
	local v = f()
	cache[id] = v == nil and NIL or v
	return v
end
function u2.resolveChunk(name)
	error("port: unexpected resolveChunk(" .. tostring(name) .. ")", 2)
end

-- wrappers that pointed into the other chunk ---------------------------------------
function u2.__fKI() -- Line: 864118
    local v120407 = {
        None = "None",
        Warning = "Warning",
        Banned = "Banned",
        Deleted = "Deleted"
    };

    return {
        INTERVENTION_TYPES = v120407,
        PUNISHMENT_TYPE_TO_INTERVENTION_MAP = {
            None = v120407.None,
            Warn = v120407.Warning,
            ["Ban 1 Hour"] = v120407.Banned,
            ["Ban 6 Hours"] = v120407.Banned,
            ["Ban 1 Day"] = v120407.Banned,
            ["Ban 3 Days"] = v120407.Banned,
            ["Ban 7 Days"] = v120407.Banned,
            ["Ban 14 Days"] = v120407.Banned,
            ["Ban 30 Days"] = v120407.Banned,
            ["Ban 60 Days"] = v120407.Banned,
            ["Ban 6 Months"] = v120407.Banned,
            ["Ban 1 Year"] = v120407.Banned,
            Delete = v120407.Deleted
        },
        VIOLATION_TYPE_TO_PLURAL_MAP = {
            ["Label.Type.Avatar"] = "Feature.AppealsPortal.Label.TypePlural.Avatar",
            ["Label.Type.Audio"] = "Feature.AppealsPortal.Label.TypePlural.Audio",
            ["Label.Type.AvatarAccessory"] = "Feature.AppealsPortal.Label.TypePlural.AvatarAccessory",
            ["Label.Type.Bundle"] = "Feature.AppealsPortal.Label.TypePlural.Bundle",
            ["Label.Type.Chat"] = "Feature.AppealsPortal.Label.TypePlural.Chat",
            ["Label.Type.CommerceProduct"] = "Feature.AppealsPortal.Label.TypePlural.CommerceProduct",
            ["Label.Type.Experience"] = "Feature.AppealsPortal.Label.TypePlural.Experience",
            ["Label.Type.Image"] = "Feature.AppealsPortal.Label.TypePlural.Image",
            ["Label.Type.Look"] = "Feature.AppealsPortal.Label.TypePlural.Look",
            ["Label.Type.Mesh"] = "Feature.AppealsPortal.Label.TypePlural.Mesh",
            ["Label.Type.Model"] = "Feature.AppealsPortal.Label.TypePlural.Model",
            ["Label.Type.Plugin"] = "Feature.AppealsPortal.Label.TypePlural.Plugin",
            ["Label.Type.Video"] = "Feature.AppealsPortal.Label.TypePlural.Video",
            ["Label.Type.Voice"] = "Feature.AppealsPortal.Label.TypePlural.Voice"
        },
        EVENT_TYPES = {
            AccountReactivationPageRendered = "accountReactivationPageRendered",
            PageRendered = "pageRendered",
            CheckboxChecked = "checkboxChecked",
            LogoutClicked = "logoutClicked",
            ReactivateClicked = "reactivateClicked",
            SecondChanceReactivateClicked = "secondChanceReactivateClicked",
            ParentVerificationClicked = "parentVerificationClicked",
            EmailVerificationClicked = "emailVerificationClicked",
            TermsOfUseClicked = "termsOfUseClicked",
            AppealsProcessClicked = "appealsProcessClicked",
            CommunityGuidelineClicked = "communityGuidelineClicked",
            UGCGuidelinesClicked = "ugcGuidelinesClicked",
            AppealsPortalClicked = "appealsPortalClicked",
            EvidenceValidationError = "evidenceValidationError",
            ContinueClicked = "continueClicked",
            BackClicked = "backClicked",
            UnmappedViolationKey = "unmappedViolationKey",
            MissingTranslation = "missingTranslation"
        },
        VERIFICATION_TYPES = {
            Parent = "VPC",
            Email = "Email"
        },
        TRANSLATION_KEYS = {
            ["Ban 1 Hour"] = "Feature.NotApproved.Heading.SuspendedOneHour",
            ["Ban 6 Hours"] = "Feature.NotApproved.Heading.SuspendedSixHours",
            ["Ban 1 Day"] = "Feature.NotApproved.Heading.SuspendedOneDay",
            ["Ban 3 Days"] = "Feature.NotApproved.Heading.SuspendedThreeDays",
            ["Ban 7 Days"] = "Feature.NotApproved.Heading.SuspendedSevenDays",
            ["Ban 14 Days"] = "Feature.NotApproved.Heading.Suspended14Days",
            ["Ban 30 Days"] = "Feature.NotApproved.Heading.Suspended30Days",
            ["Ban 60 Days"] = "Feature.NotApproved.Heading.SuspendedSixtyDays",
            ["Ban 6 Months"] = "Feature.NotApproved.Heading.SuspendedSixMonths",
            ["Ban 1 Year"] = "Feature.NotApproved.Heading.Suspended1Year",
            Warn = "Feature.NotApproved.Heading.Warning",
            Delete = "Feature.NotApproved.Heading.Banned",
            genericSuspended = "Feature.NotApproved.Heading.Suspended",
            chargebackNextSteps = "Feature.NotApproved.Label.ChargebackNextSteps",
            parentVerificationButton = "Feature.NotApproved.Label.ParentVerificationButtonText",
            parentReactivationNotice = "Feature.NotApproved.Label.ParentReactivationNoticeUA",
            emailReactivationNotice = "Feature.NotApproved.Label.EmailReactivationNoticeUA",
            emailVerificationButton = "Feature.NotApproved.Label.EmailVerificationButtonText",
            latestActivityLabel = "Feature.NotApproved.Label.LatestActivity",
            latestActivityLabelKids = "Feature.NotApproved.Heading.RecentlyChecked",
            viewMoreButton = "Feature.NotApproved.Action.ViewMore",
            viewLessButton = "Feature.NotApproved.Action.ViewLess",
            moderatorNoteLabel = "Feature.NotApproved.Label.ModeratorNote",
            reasonLabel = "Feature.NotApproved.Label.Reason",
            otherAbuseType = "Feature.NotApproved.Label.AbuseType.Other",
            offensiveItemLabel = "Feature.NotApproved.Label.OffensiveItem.V2",
            dateReviewedLabel = "Feature.NotApproved.Label.ReviewDate",
            decisionMethodLabel = "Feature.NotApproved.Label.DecisionMethod",
            whatHappenedLabel = "Feature.NotApproved.Label.WhatHappened",
            whatHappenedLabelKids = "Feature.NotApproved.Heading.Why",
            fallbackModeratorNote = {
                "Feature.NotApproved.Description.Violation",
                startLink = "",
                endLink = ""
            },
            communityStandardsLabel = "Feature.NotApproved.Label.CommunityStandards",
            avatarGuidelinesLabel = "Feature.NotApproved.Action.ViewRulesUGCAvatarGuidelines",
            preventionStepsHeading = "Feature.NotApproved.Label.RuleBreakingAddsUp",
            preventionStepsHeadingKids = "Feature.NotApproved.Heading.WhatNext",
            foreshadowDescription = "Feature.NotApproved.Description.Foreshadow",
            foreshadowDescriptionKids = "Feature.NotApproved.Description.Foreshadow.Kids",
            linkedAccountsDescription = "Feature.NotApproved.Description.LinkedAccounts",
            followTheRulesDescription = "Feature.NotApproved.Description.FollowTheRules",
            viewRulesButton = "Feature.NotApproved.Action.ViewRules",
            reportMistakeHeading = "Feature.NotApproved.Label.Mistake",
            reportMistakeDescription = "Feature.NotApproved.Description.Mistake",
            reportMistakeDescriptionV2 = "Feature.NotApproved.Description.Mistake.V2",
            reportMistakeDescriptionV3 = "Feature.NotApproved.Description.Mistake.V3",
            reportMistakeDescriptionKids = "Feature.NotApproved.Description.Mistake.Kids",
            continueButton = "Feature.NotApproved.Action.Continue",
            reportMistakeButton = "Feature.NotApproved.Action.ReportMistake",
            checkboxLabel = "Feature.NotApproved.Action.RuleConfirmation",
            acknowledgementCheckboxLabel = "Feature.NotApproved.Label.RuleAcknowledgment",
            suspensionLabel = "Feature.NotApproved.Label.Suspension",
            errorMessage = "Feature.NotApproved.Heading.Error",
            appealsPortalTitle = "Feature.AppealsPortal.Label.ReportAndAppeals",
            accountStatusTitle = "Feature.SafetyDashboard.Heading.AccountStatus.V2",
            sendAppealButton = "Feature.AppealsPortal.Action.SendAppeal",
            secondChanceIntroHeading = "Feature.NotApproved.Heading.SecondChance",
            secondChanceIntroDescription = "Feature.NotApproved.Description.SecondChance.Second",
            secondChanceConclusionHeading = "Feature.NotApproved.Heading.SecondChance.Details",
            secondChanceConclusionDescription = "Feature.NotApproved.Description.SecondChance.Details",
            reactivationNoticeHeading = "Feature.NotApproved.Heading.ReactivationNotice",
            reactivationNoticeDescription = "Feature.NotApproved.Description.ReactivationNotice",
            okButton = "CommonUI.Controls.Action.OK",
            backButton = "CommonUI.Controls.Action.Back",
            logoutButton = "Application.Logout.Action.Logout"
        },
        COMMUTATION_CATEGORIES = {
            Educational = "EDUCATIONAL_PASS"
        }
    };
end;

u2.fOY = function() return { AppUserLayers = keyProxy() } end
u2.fPa = function()
	return {
		Constants = u2.__fKI(),
		SetModerationStatus = thunk,
		GetModerationStore = function() return noopProxy() end,
	}
end
u2.fPb = function() return game end
u2.fPd = function() return Cryo end
u2.fPf = function() return React end
u2.fPg = function() return FoundationShim end
u2.fPi = function() return setmetatable({ assert = function() end, isType = function() end }, { __index = function() return function() end end }) end
u2.fPp = function()
	return {
		Localization = {
			new = function()
				return setmetatable({}, {
					__index = function(_, method)
						return function(_, key, params) return format(key, params) end
					end,
				})
			end,
		},
	}
end
u2.fPq = function() return SharedFlags end
u2.fPx = function() return tPkg end
u2.fPA = function()
	return {
		RobloxLocaleIdKey = LOCALE_KEY,
		Hooks = {
			useLocalization = function(map)
				return React.useMemo(function() return localizeMap(map) end, { map })
			end,
		},
	}
end
u2.fPE = function()
	local function LinkButton(props)
		return React.createElement(Foundation.Button, {
			text = props.text,
			onActivated = props.onActivated,
			variant = Foundation.Enums.ButtonVariant.Link or Foundation.Enums.ButtonVariant.Standard,
			LayoutOrder = props.layoutOrder,
		})
	end
	return { App = { Button = { LinkButton = LinkButton } } }
end
u2.fPH = function() return { AppPage = keyProxy(), NotificationType = keyProxy() } end
u2.fPI = function() return { Thunks = { NavigateBack = thunk, NavigateDown = NavigateDown } } end
u2.fPJ = function() return UrlBuilderPkg end
u2.fPK = function() return { NavigationCommands = noopProxy() } end
u2.fPM = function() return { AppGuiService = {}, AppLinking = {}, RoactNetworking = {} } end
u2.fPN = function() return { useRoactService = function() return OFFLINE_SERVICE end } end
u2.fPO = function()
	return { usePreferredInput = function() return "Pointer" end, Input = { Directional = "Directional", Pointer = "Pointer" } }
end
u2.fPP = function() return { Hooks = { RoactRodux = { useDispatch = function() return dispatch end } } } end
u2.fQe = function()
	return {
		useAppFocusRoot = function() return nil end,
		FocusNavigableSurfaceIdentifierEnum = keyProxy(),
		FocusNavigationEventNameEnum = keyProxy(),
	}
end
u2.fQf = function() return {} end
u2.fQi = function() return InputHandlers or { onRelease = function(cb) return cb end } end
u2.fQn = function() return BuilderIcons end
u2.fQr = function() return Promise end
u2.fQw = function() return { Url = { APIS_URL = "https://apis.roblox.com/" } } end
u2.fQD = function() return { Thunks = { ConsoleDisconnect = thunk }, Enums = { LogoutReasonNames = keyProxy() } } end
u2.fQJ = function()
	return {
		useAppPolicy = function(selector)
			local ok, v = pcall(selector, {})
			return ok and v or nil
		end,
	}
end

-- offline replacements for internal modules ----------------------------------------
u2.fPk = function() return function() end end -- sendNotApprovedPageEvent (analytics)
u2.fQy = function() -- GetCommutationEligibility
	return function() return Promise.resolve({ responseBody = { educational_pass_eligible = false } }) end
end
u2.fQv = function() return offline end -- PostConsequenceCommutation
u2.fQq = function() return offline end -- PostReactivateAccount
-- Log Out = Alt+F4. Alt+F4 goes to whatever window is in front, so it's only sent while
-- Roblox is the foreground window (never closes another app by accident). Keys are always
-- released in the same burst, so Alt can't get stuck down.
local loggingOut = false
local function robloxInFront()
	if type(isrbxactive) == "function" then
		local okA, active = pcall(isrbxactive)
		if okA then return active == true end
	end
	return true -- can't check: the click that got us here was on Roblox
end
local function sendAltF4()
	pcall(keypress, 0x12)   -- Alt down
	pcall(keypress, 0x73)   -- F4 down
	pcall(keyrelease, 0x73) -- F4 up
	pcall(keyrelease, 0x12) -- Alt up
end
local function doLogout(source)
	if loggingOut then return end
	if type(keypress) ~= "function" or type(keyrelease) ~= "function" then
		log("logout: keypress/keyrelease unavailable")
		return
	end
	loggingOut = true
	log("logout: triggered by", tostring(source))
	task.spawn(function()
		for attempt = 1, 5 do
			if not robloxInFront() then
				log("logout: Roblox not in front, Alt+F4 skipped (attempt " .. attempt .. ")")
				break
			end
			log("logout: Alt+F4 attempt " .. attempt)
			sendAltF4()
			task.wait(0.5)
		end
		loggingOut = false -- still alive -> Log Out can be pressed again
	end)
end
u2.fQC = function() -- useLogout: close the Roblox client with Alt+F4 (no real sign-out)
	return function()
		return function()
			doLogout("Log Out button")
		end
	end
end
u2.fPL = function() return function(url, title) return function() openWeb(url, title) end end end -- useOpenLink
u2.fPQ = function() return function(url, title) return function() openWeb(url, title) end end end -- useWebView

-- Roblox's page modules (verbatim) --------------------------------------------------
function u2.fPc() -- Line: 55510
    -- upvalues: u2 (ref)
    local _ = u2.loadModule("fPa").Constants;

    return {};
end;

function u2.fOZ() -- Line: 55531
    -- upvalues: u2 (ref)
    local INTERVENTION_TYPES = u2.loadModule("fPa").Constants.INTERVENTION_TYPES;
    local u8196 = u2.loadModule("fPb");
    u2.loadModule("fPc");

    return function(p8197, p8198, p8199) -- Line: 55544, Name: canReactivate
        -- upvalues: u8196 (copy), INTERVENTION_TYPES (copy)
        if p8199 ~= "" then
            return true;
        end;

        local v8200 = u8196.Workspace:GetServerTimeNow() * 1000;
        local DateTime_fromIsoDate_ret = DateTime.fromIsoDate(p8198);

        if DateTime_fromIsoDate_ret then
            DateTime_fromIsoDate_ret = DateTime_fromIsoDate_ret.UnixTimestampMillis < v8200;
        end;

        return p8197 == INTERVENTION_TYPES.Warning and true or (p8197 == INTERVENTION_TYPES.Banned and DateTime_fromIsoDate_ret and true or false);
    end;
end;

function u2.fPj() -- Line: 55846
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8201 = u2.loadModule("fPf");
    local View = u2.loadModule("fPg").View;

    return {
        renderPageItemsFromList = function(p8202, p8203, p8204, p8205, p8206, p8207, p8208, p8209) -- Line: 55884, Name: renderPageItemsFromList
            -- upvalues: u8201 (copy), View (copy)
            local v8210 = {};

            for i, v in ipairs(p8202) do
                if v.getIsVisible(p8203, p8205, p8208, p8209) then
                    local v8211 = u8201.createElement(v.renderComponent, {
                        moderationDetail = p8203,
                        layoutOrder = i,
                        dispatch = p8204,
                        hasEducationalPages = p8206
                    });

                    if p8207 == false then
                        table.insert(v8210, u8201.createElement(View, {
                            tag = "size-full-0 auto-y padding-bottom-large",
                            LayoutOrder = i
                        }, {
                            Content = v8211
                        }));
                    else
                        table.insert(v8210, v8211);
                    end;
                end;
            end;

            return v8210;
        end,

        EDUCATIONAL_PAGE_PREFIXES = {
            Rule = "policy-rule-",
            Importance = "policy-importance-"
        },
        STATIC_PAGE_NAMES = {
            Intro = "intro",
            Resolution = "resolution",
            SecondChanceIntro = "second-chance-intro",
            SecondChanceConclusion = "second-chance-conclusion",
            Unknown = "unknown"
        }
    };
end;

function u2.fPo() -- Line: 55977
    return function(p8216) -- Line: 55979, Name: splitByNewlines
        local v8217 = {};

        for i in string.gmatch(p8216, "[^\n]+") do
            local string_match_ret = string.match(i, "^%s*(.-)%s*$");

            if string_match_ret and string_match_ret ~= "" then
                table.insert(v8217, string_match_ret);
            end;
        end;

        return v8217;
    end;
end;

function u2.fPn() -- Line: 56009
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8218 = u2.loadModule("fPo");
    u2.loadModule("fPj");
    local u8219 = u2.loadModule("fPf");
    local v8220 = u2.loadModule("fPg");
    local Text = v8220.Text;
    local View = v8220.View;
    local Localization = u2.loadModule("fPp").Localization;
    local LocalizationService = game:GetService("LocalizationService");
    local u8221 = Localization.new(LocalizationService.RobloxLocaleId);

    return function(u8222) -- Line: 56037, Name: createPolicyEducationConfig
        -- upvalues: u8221 (copy), u8218 (copy), u8219 (copy), Text (copy), View (copy)
        return {
            getIsVisible = function(p8223, p8224) -- Line: 56124, Name: getIsVisible
                return true;
            end,

            renderComponent = u8219.memo(function(p8225) -- Line: 56039, Name: PolicyEducationConfig
                -- upvalues: u8222 (copy), u8221 (ref), u8218 (ref), u8219 (ref), Text (ref), View (ref)
                local v8226;

                if u8222.description and u8222.description ~= "" then
                    v8226 = u8221:Format(u8222.description);
                else
                    v8226 = nil;
                end;

                local v8227 = not v8226 and {} or u8218(v8226);
                local v8228;

                if u8222.descriptionBullets and u8222.descriptionBullets ~= "" then
                    v8228 = u8221:Format(u8222.descriptionBullets);
                else
                    v8228 = nil;
                end;

                local v8229 = not v8228 and {} or u8218(v8228);
                local v8230 = {};

                for i, v in v8227 do
                    table.insert(v8230, u8219.createElement(Text, {
                        tag = "auto-xy text-body-large text-wrap text-align-x-left",
                        Text = v,
                        LayoutOrder = i
                    }));
                end;

                local v8231 = {};

                for i, v in v8229 do
                    local createElement = u8219.createElement;
                    local v8232 = {
                        BulletIcon = u8219.createElement(Text, {
                            Text = "•",
                            tag = "auto-xy text-body-large",
                            LayoutOrder = 1
                        }),
                        BulletText = u8219.createElement(Text, {
                            tag = "auto-xy text-body-large text-wrap text-align-x-left",
                            LayoutOrder = 2,
                            Text = v
                        })
                    };
                    table.insert(v8231, createElement(View, {
                        tag = "row gap-small auto-xy",
                        LayoutOrder = i
                    }, v8232));
                end;

                local createElement = u8219.createElement;
                local v8233 = {
                    tag = "col gap-medium size-full-0 auto-y",
                    LayoutOrder = p8225.layoutOrder
                };
                local v8234 = {
                    Title = u8219.createElement(Text, {
                        tag = "auto-xy text-heading-medium text-wrap text-align-x-left content-emphasis",
                        LayoutOrder = 1,
                        Text = u8221:Format(u8222.title)
                    })
                };
                local v8235;

                if u8222.subtitle then
                    v8235 = u8219.createElement(Text, {
                        tag = "auto-xy text-title-large text-wrap text-align-x-left content-emphasis",
                        LayoutOrder = 2,
                        Text = u8221:Format(u8222.subtitle)
                    });
                else
                    v8235 = nil;
                end;

                v8234.Subtitle = v8235;
                local createElement2 = u8219.createElement;
                local v8236 = {
                    tag = "col gap-small size-full-0 auto-y",
                    LayoutOrder = 3
                };
                local v8237 = {};
                local v8238;

                if #v8227 > 0 then
                    v8238 = u8219.createElement(View, {
                        tag = "col gap-medium auto-xy",
                        LayoutOrder = 1
                    }, unpack(v8230));
                else
                    v8238 = false;
                end;

                v8237.Description = v8238;
                local v8239;

                if #v8229 > 0 then
                    v8239 = u8219.createElement(View, {
                        tag = "col gap-xsmall auto-xy padding-x-large",
                        LayoutOrder = 2
                    }, unpack(v8231));
                else
                    v8239 = false;
                end;

                v8237.Bullets = v8239;
                v8234.ContentSection = createElement2(View, v8236, v8237);

                return createElement(View, v8233, v8234);
            end)
        };
    end;
end;

function u2.fPt() -- Line: 56143
    local v8240 = {
        ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.Dating",
        ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.Dating",
        ruleDescription = "Feature.NotApproved.Description.RuleExplanation.Dating",
        importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
        importanceDescription = "Feature.NotApproved.Description.RuleImportance.Dating",
        policyKey = "dating"
    };
    local v8241 = {
        ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.BullyingHarassmentDiscrimination",
        ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.BullyingHarassmentDiscrimination",
        ruleDescription = "Feature.NotApproved.Description.RuleExplanation.BullyingHarassmentDiscrimination",
        importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
        importanceDescription = "Feature.NotApproved.Description.RuleImportance.BullyingHarassmentDiscrimination",
        policyKey = "bullying-harassment-discrimination"
    };
    local v8242 = {
        ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.MisusingRobloxSystems",
        ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.MisusingRobloxSystems",
        ruleDescription = "Feature.NotApproved.Description.RuleExplanation.MisusingRobloxSystems",
        ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.MisusingRobloxSystems",
        importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
        importanceDescription = "Feature.NotApproved.Description.RuleImportance.MisusingRobloxSystems",
        policyKey = "misusing-roblox-systems"
    };
    local v8243 = {
        ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.PII",
        ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.PII",
        ruleDescription = "Feature.NotApproved.Description.RuleExplanation.PII",
        ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.PII",
        importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
        importanceDescription = "Feature.NotApproved.Description.RuleImportance.PII",
        policyKey = "pii"
    };
    local v8244 = {
        ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.SSHAndIllegalRegulatedActivities",
        ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.SSHAndIllegalRegulatedActivities",
        ruleDescription = "Feature.NotApproved.Description.RuleExplanation.SSHAndIllegalRegulatedActivities",
        ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.SSHAndIllegalRegAct",
        importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
        importanceDescription = "Feature.NotApproved.Description.RuleImportance.SSHAndIllegalRegulatedActivities",
        policyKey = "ssh-and-illegal-regulated-activities"
    };

    return {
        ["Label.AbuseType.CheatandExploits"] = v8242,
        ["Label.AbuseType.ContestsandSweepstakes"] = v8244,
        ["Label.AbuseType.Dating"] = v8240,
        ["Label.AbuseType.DirectingUsersOffPlatform"] = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.DirectingUsersOffPlatform",
            ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.DirectingUsersOffPlatform",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.DirectingUsersOffPlatform",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
            importanceDescription = "Feature.NotApproved.Description.RuleImportance.DirectingUsersOffPlatform",
            policyKey = "directing-users-off-platform"
        },
        ["Label.AbuseType.DiscriminatoryContent"] = v8241,
        ["Label.AbuseType.DisruptiveAudio"] = v8242,
        ["Label.AbuseType.EncouragingDangerousBehavior"] = v8244,
        ["Label.AbuseType.ExtortionandBlackmail"] = v8241,
        ["Label.AbuseType.Harassment"] = v8241,
        ["Label.AbuseType.IllegalandRegulatedContent"] = v8244,
        ["Label.AbuseType.Impersonation"] = v8241,
        ["Label.AbuseType.IrlDangerousActivities"] = v8244,
        ["Label.AbuseType.MisusingRobloxSystems"] = v8242,
        ["Label.AbuseType.OffPlatformSpeechandBehavior"] = v8241,
        ["Label.AbuseType.PrivacyAskingforPII"] = v8243,
        ["Label.AbuseType.PrivacyGivingPII"] = v8243,
        ["Label.AbuseType.RealLifeThreats"] = v8241,
        ["Label.AbuseType.Scamming"] = v8242,
        ["Label.AbuseType.SexualContent"] = v8240,
        ["Label.AbuseType.Spam"] = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.Spam",
            ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.Spam",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.Spam",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
            importanceDescription = "Feature.NotApproved.Description.RuleImportance.Spam",
            policyKey = "spam"
        },
        ["Label.AbuseType.SuicideSelfHarm"] = v8244,
        ["Label.AbuseType.Swearing"] = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.Swearing",
            ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.Swearing",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.Swearing",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
            importanceDescription = "Feature.NotApproved.Description.RuleImportance.Swearing",
            policyKey = "swearing"
        },
        ["Label.AbuseType.ThreatsOrAbuseOfRobloxEmployeesOrAffiliates"] = v8241,
        ["Label.AbuseType.ViolentContentAndGore"] = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.ViolentContentAndGore",
            ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.ViolentContentAndGore",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.ViolentContentAndGore",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
            importanceDescription = "Feature.NotApproved.Description.RuleImportance.ViolentContentAndGore",
            policyKey = "violent-content-and-gore"
        },
        ["Label.AbuseType.VirtualCasino"] = v8244,
        ["Label.Sublabel.RealLifeEvents"] = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.RealLifeEvents",
            ruleSubtitle = "Feature.NotApproved.SubHeading.RuleExplanation.RealLifeEvents",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.RealLifeEvents",
            ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.RealLifeEvents",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance",
            importanceDescription = "Feature.NotApproved.Description.RuleImportance.RealLifeEvents",
            policyKey = "real-life-events"
        },
        ["Label.Sublabel.RomanceOrSex"] = v8240
    };
end;

function u2.fPs() -- Line: 56275
    -- upvalues: u2 (ref)
    u2.loadModule("fPt");
    local v8245 = {
        displayLabel = "Feature.NotApproved.Label.AbuseType.SharingPII.Kids",
        moderatorNote = "Feature.NotApproved.Label.AbuseType.SharingPII.Note.Kids",
        education = {
            ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.SharingPII.Kids",
            ruleDescription = "Feature.NotApproved.Description.RuleExplanation.SharingPII.Kids",
            ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.SharingPII.Kids",
            importanceTitle = "Feature.NotApproved.Heading.RuleImportance.Kids",
            importanceDescriptionBullets = "Feature.NotApproved.Description.RuleImportance.Bullets.SharingPII.Kids",
            policyKey = "kids-sharing-pii",
            deduplicationKey = "pii"
        }
    };
    local v8246 = {
        ["Label.AbuseType.Harassment"] = {
            displayLabel = "Feature.NotApproved.Label.AbuseType.Bullying.Kids",
            moderatorNote = "Feature.NotApproved.Label.AbuseType.Bullying.Note.Kids",
            education = {
                ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.Bullying.Kids",
                ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.Bullying.Kids",
                importanceTitle = "Feature.NotApproved.Heading.RuleImportance.Kids",
                importanceDescription = "Feature.NotApproved.Description.RuleImportance.Bullying.Kids",
                policyKey = "kids-bullying",
                deduplicationKey = "bullying-harassment-discrimination"
            }
        },
        ["Label.AbuseType.PrivacyAskingforPII"] = v8245,
        ["Label.AbuseType.PrivacyGivingPII"] = v8245,
        ["Label.AbuseType.SexualContent"] = {
            displayLabel = "Feature.NotApproved.Label.AbuseType.SexualContent.Kids",
            moderatorNote = "Feature.NotApproved.Label.AbuseType.SexualContent.Note.Kids",
            education = {
                ruleTitle = "Feature.NotApproved.Heading.RuleExplanation.SexualContent.Kids",
                ruleDescriptionBullets = "Feature.NotApproved.Description.RuleExplanation.Bullets.SexualContent.Kids",
                importanceTitle = "Feature.NotApproved.Heading.RuleImportance.Kids",
                importanceDescription = "Feature.NotApproved.Description.RuleImportance.SexualContent.Kids",
                policyKey = "kids-sexual-content",
                deduplicationKey = "dating"
            }
        }
    };
    local v8247 = {};

    for _, v in v8246 do
        v8247[v.displayLabel] = v.displayLabel;
        v8247[v.moderatorNote] = v.moderatorNote;
    end;

    return {
        CONTENT_BY_ABUSE_KEY = v8246,
        TRANSLATION_KEYS = v8247
    };
end;

function u2.fPr() -- Line: 56341
    -- upvalues: u2 (ref)
    local u8248 = u2.loadModule("fPs");
    local u8249 = u2.loadModule("fPt");

    return function(p8250, p8251) -- Line: 56348, Name: resolvePolicyEducationContent
        -- upvalues: u8248 (copy), u8249 (copy)
        local v8252 = p8251 and u8248.CONTENT_BY_ABUSE_KEY[p8250];

        if v8252 then
            return v8252.education;
        end;

        return u8249[p8250];
    end;
end;

function u2.fPv() -- Line: 56365
    -- upvalues: u2 (ref)
    local u8253 = u2.loadModule("fPf");
    local v8254 = u2.loadModule("fPg");
    local View = v8254.View;
    local Text = v8254.Text;

    return u8253.memo(function(p8255) -- Line: 56378, Name: EvidenceField
        -- upvalues: u8253 (copy), View (copy), Text (copy)
        local createElement = u8253.createElement;
        local v8256 = {
            tag = "col size-full-0 auto-y gap-xxsmall",
            LayoutOrder = p8255.layoutOrder
        };
        local v8257 = {};
        local createElement2 = u8253.createElement;
        local v8258 = {
            tag = "auto-xy text-title-medium text-wrap text-align-x-left content-default",
            LayoutOrder = 1
        };
        local v8259;

        if p8255.showColon == false then
            v8259 = p8255.fieldLabel;
        else
            v8259 = `{p8255.fieldLabel}:`;
        end;

        v8258.Text = v8259;
        v8257.Label = createElement2(Text, v8258);
        v8257.Value = u8253.createElement(Text, {
            tag = "auto-xy text-body-medium text-wrap text-align-x-left",
            LayoutOrder = 2,
            Text = p8255.fieldValue
        });

        return createElement(View, v8256, v8257);
    end);
end;

function u2.fPy() -- Line: 56410
    return __DefineFastFlag("NapPublicEvidenceTranslationKeys", false);
end;

function u2.fPw() -- Line: 56414
    -- upvalues: u2 (ref)
    local v8260 = u2.loadModule("fPx");
    local v8261 = u2.loadModule("fPy");
    local u8262 = {
        validateViolation = v8260.interface({
            evidence = v8260.interface({
                type = v8260.literal("platform"),
                elements = v8260.table,
                displayMeta = v8260.optional(v8260.interface({
                    lowercaseKey = v8260.match(".+"),
                    capitalizedKey = v8260.match(".+"),
                    icon = v8260.match(".+")
                }))
            }),
            abuseTypeTranslationKeys = v8260.table,
            uid = v8260.match(".+")
        })
    };
    local v8263 = v8260.interface({
        type = v8260.literal("image"),
        labelKey = v8260.match(".+"),
        url = v8260.match(".+"),
        altLabelKey = v8260.optional(v8260.match(".+"))
    });
    local v8264 = v8260.interface({
        type = v8260.literal("timestamp"),
        labelKey = v8260.match(".+"),
        unix = v8260.numberMin(1)
    });
    local v8265;

    if v8261 then
        v8265 = v8260.intersection(v8260.interface({
            type = v8260.literal("text"),
            labelKey = v8260.match(".+"),
            text = v8260.optional(v8260.match(".+")),
            textKey = v8260.optional(v8260.match(".+")),
            textKeyParameters = v8260.optional(v8260.table)
        }), function(p8266) -- Line: 56467
            if not (p8266.text or p8266.textKey) then
                return false, "textElement must have at least one of \'text\' or \'textKey\'";
            end;

            if p8266.textKeyParameters and not p8266.textKey then
                return false, "textKeyParameters requires textKey to be present";
            end;

            return true, "";
        end);
    else
        v8265 = v8260.interface({
            type = v8260.literal("text"),
            text = v8260.match(".+"),
            labelKey = v8260.match(".+")
        });
    end;

    u8262.checkElementIsVisible = v8260.union(v8265);
    u8262.checkElementIsValid = v8260.union(v8265, v8264, v8263);

    function u8262.filterForVisibleElements(p8267) -- Line: 56492
        -- upvalues: u8262 (copy)
        local v8268 = {};

        for _, v in p8267 do
            if u8262.checkElementIsValid(v) and u8262.checkElementIsVisible(v) then
                table.insert(v8268, v);
            end;
        end;

        return v8268;
    end;

    function u8262.isVisibleInView(p8269) -- Line: 56504
        -- upvalues: u8262 (copy)
        if u8262.validateViolation(p8269) and #p8269.evidence.elements ~= 0 then
            return #u8262.filterForVisibleElements(p8269.evidence.elements) > 0;
        end;

        return false;
    end;

    return u8262;
end;

function u2.fPz() -- Line: 56525
    -- upvalues: u2 (ref)
    local RobloxLocaleIdKey = u2.loadModule("fPA").RobloxLocaleIdKey;
    u2.loadModule("fPc");

    return function(p8270, p8271, p8272) -- Line: 56534, Name: parseDateFromString
        -- upvalues: RobloxLocaleIdKey (copy)
        local DateTime_fromIsoDate_ret = DateTime.fromIsoDate(p8270);

        if DateTime_fromIsoDate_ret then
            return DateTime_fromIsoDate_ret:FormatLocalTime(p8272 or "LLL", p8271[RobloxLocaleIdKey]);
        end;

        return p8270;
    end;
end;

function u2.fPC() -- Line: 56548
    -- upvalues: u2 (ref)
    local u8273 = u2.loadModule("fPs");
    u2.loadModule("fPc");

    return function(p8274, p8275) -- Line: 56557, Name: collectKidsTranslations
        -- upvalues: u8273 (copy)
        local v8276 = {};
        local v8277 = {};

        for _, v in p8274 do
            local v8278 = u8273.CONTENT_BY_ABUSE_KEY[v];
            local v8279;

            if v8278 then
                v8279 = v8278.displayLabel;
            else
                v8279 = v;
            end;

            local v8280 = p8275[v8279];

            if v8280 and (v8280 ~= "" and not v8276[v8280]) then
                v8276[v8280] = true;
                table.insert(v8277, v8280);
            end;
        end;

        return v8277;
    end;
end;

function u2.fPD() -- Line: 56579
    -- upvalues: u2 (ref)
    local u8281 = u2.loadModule("fPd");

    return function(p8282, p8283) -- Line: 56586
        -- upvalues: u8281 (copy)
        local v8284 = {};

        for _, v in p8282 do
            local v8285;

            if p8283 then
                v8285 = p8283[v];
            else
                v8285 = v;
            end;

            if v8285 and v8285 ~= "" then
                v8284[v8285] = true;
            end;
        end;

        return u8281.Dictionary.keys(v8284);
    end;
end;

function u2.fPB() -- Line: 56603
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8286 = u2.loadModule("fPi");
    local u8287 = u2.loadModule("fPf");
    local useMemo = u8287.useMemo;
    local useContext = u8287.useContext;
    local u8288 = u2.loadModule("fPC");
    local u8289 = u2.loadModule("fPD");
    local u8290 = u2.loadModule("fPs");
    local u8291 = u2.loadModule("fPw");
    local u8292 = u8287.createContext({});

    return {
        NotApprovedPageProvider = function(p8293) -- Line: 56632, Name: NotApprovedPageProvider
            -- upvalues: useMemo (copy), u8291 (copy), u8289 (copy), u8288 (copy), u8290 (copy), u8287 (copy), u8292 (copy)
            local translations = p8293.translations;
            local badUtterances = p8293.moderationDetail.badUtterances;
            local violation = p8293.moderationDetail.violation;
            local commutationEligibility = p8293.commutationEligibility;
            local u8294 = p8293.isKidsTreatment or false;
            local labelTranslationKey = p8293.moderationDetail.labelTranslationKey;
            local messageToUser = p8293.moderationDetail.messageToUser;
            local v8301 = useMemo(function() -- Line: 56641
                -- upvalues: violation (copy), u8291 (ref), badUtterances (copy), u8289 (ref), u8294 (copy), u8288 (ref), translations (copy), messageToUser (copy), labelTranslationKey (copy), u8290 (ref), commutationEligibility (copy)
                local v8295 = {};

                if violation and u8291.isVisibleInView(violation) then
                    v8295 = violation.abuseTypeTranslationKeys;
                elseif badUtterances then
                    for _, v in badUtterances do
                        table.insert(v8295, v.labelTranslationKey);
                    end;
                end;

                local v8296 = u8289(v8295, nil);
                local v8297;

                if u8294 then
                    v8297 = u8288(v8295, translations);
                else
                    v8297 = u8289(v8295, translations);
                end;

                local v8298;

                if messageToUser and messageToUser ~= "" then
                    v8298 = messageToUser;
                else
                    v8298 = translations.fallbackModeratorNote;
                end;

                local v8299;

                if u8294 and labelTranslationKey then
                    local v8300 = u8290.CONTENT_BY_ABUSE_KEY[labelTranslationKey];

                    if v8300 then
                        v8299 = translations[v8300.moderatorNote];
                    else
                        v8299 = nil;
                    end;

                    if v8299 then
                        if v8299 == "" then
                            v8299 = v8298;
                        end;
                    else
                        v8299 = v8298;
                    end;
                else
                    v8299 = v8298;
                end;

                return {
                    translations = translations,
                    violationReasons = {
                        translatedReasons = v8297,
                        untranslatedReasons = v8296
                    },
                    commutationEligibility = commutationEligibility,
                    isKidsTreatment = u8294,
                    moderatorNote = v8299
                };
            end, {
                badUtterances,
                violation,
                translations,
                commutationEligibility,
                u8294,
                labelTranslationKey,
                messageToUser
            });

            return u8287.createElement(u8292.Provider, {
                value = v8301
            }, p8293.children);
        end,

        useNotApprovedPageContext = function() -- Line: 56698, Name: useNotApprovedPageContext
            -- upvalues: useContext (copy), u8292 (copy), u8286 (copy)
            local v8302 = useContext(u8292);
            local v8303;

            if v8302 then
                v8303 = v8302.translations;
            else
                v8303 = v8302;
            end;

            u8286.assert(v8303, "useNotApprovedPageContext returned invalid context, usually this means the NotApprovedPageProvider is not present in the tree");

            return {
                translations = v8302.translations,
                violationReasons = v8302.violationReasons,
                commutationEligibility = v8302.commutationEligibility,
                isKidsTreatment = v8302.isKidsTreatment,
                moderatorNote = v8302.moderatorNote
            };
        end
    };
end;

function u2.fPu() -- Line: 56743
    -- upvalues: u2 (ref)
    local u8304 = u2.loadModule("fPv");
    local u8305 = u2.loadModule("fPw");
    local u8306 = u2.loadModule("fPz");
    u2.loadModule("fPc");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    u2.loadModule("fPj");
    local u8307 = u2.loadModule("fPf");
    local useState = u8307.useState;
    local useCallback = u8307.useCallback;
    local useMemo = u8307.useMemo;
    local v8308 = u2.loadModule("fPg");
    local Text = v8308.Text;
    local View = v8308.View;
    local Divider = v8308.Divider;
    local LinkButton = u2.loadModule("fPE").App.Button.LinkButton;

    local function BadUtterancesContent(p8309) -- Line: 56780
        -- upvalues: useNotApprovedPageContext (copy), useState (copy), useCallback (copy), useMemo (copy), u8307 (copy), Text (copy), View (copy), LinkButton (copy)
        local translations = useNotApprovedPageContext().translations;
        local u8310, u8311 = useState(false);
        local badUtterances = p8309.badUtterances;
        local v8313 = useCallback(function() -- Line: 56786
            -- upvalues: u8311 (copy)
            u8311(function(p8312) -- Line: 56787
                return not p8312;
            end);
        end, { u8310 });
        local u8314 = useMemo(function() -- Line: 56792
            -- upvalues: u8310 (copy), badUtterances (copy)
            return not u8310 and #badUtterances > 4 and { unpack(badUtterances, 1, 4) } or badUtterances;
        end, { badUtterances, u8310 });
        local v8316 = useMemo(function() -- Line: 56798
            -- upvalues: u8314 (copy), u8307 (ref), Text (ref)
            local v8315 = {};

            for i, v in u8314 do
                table.insert(v8315, u8307.createElement(Text, {
                    tag = "auto-xy text-body-medium text-align-x-left text-wrap",
                    RichText = true,
                    Text = v.utteranceText,
                    LayoutOrder = i
                }));
            end;

            return v8315;
        end, { u8314 });
        local createElement = u8307.createElement;
        local v8317 = {
            tag = "auto-xy col gap-small",
            LayoutOrder = p8309.LayoutOrder
        };
        local v8318 = {
            BadUtteranceItems = u8307.createElement(View, {
                tag = "auto-xy col gap-xxsmall",
                LayoutOrder = 1
            }, {
                OffensiveItemLabel = u8307.createElement(Text, {
                    tag = "auto-xy text-title-medium text-align-x-left text-wrap content-default",
                    RichText = true,
                    LayoutOrder = 1,
                    Text = `{translations.offensiveItemLabel}:`
                }),
                ListOfItems = u8307.createElement(View, {
                    tag = "auto-xy col",
                    LayoutOrder = 2
                }, unpack(v8316))
            })
        };
        local v8319;

        if #badUtterances > 4 then
            local createElement2 = u8307.createElement;
            local v8320 = {
                fontStyle = "CaptionHeader",
                minPaddingX = 0,
                minPaddingY = 0,
                layoutOrder = 2
            };
            local v8321;

            if u8310 then
                v8321 = translations.viewLessButton;
            else
                v8321 = translations.viewMoreButton;
            end;

            v8320.text = v8321;
            v8320.onActivated = v8313;
            v8319 = createElement2(LinkButton, v8320) or nil;
        else
            v8319 = nil;
        end;

        v8318.ToggleButton = v8319;

        return createElement(View, v8317, v8318);
    end;

    return {
        getIsVisible = function(p8322) -- Line: 56880, Name: getIsVisible
            -- upvalues: u8305 (copy)
            local badUtterances = p8322.badUtterances;
            local v8323 = not u8305.isVisibleInView(p8322.violation);

            if v8323 then
                if badUtterances then
                    badUtterances = #badUtterances ~= 0;
                end;
            else
                badUtterances = v8323;
            end;

            return badUtterances;
        end,

        renderComponent = u8307.memo(function(p8324) -- Line: 56849, Name: BadUtterances
            -- upvalues: useNotApprovedPageContext (copy), u8307 (copy), View (copy), BadUtterancesContent (copy), Divider (copy), u8304 (copy), u8306 (copy)
            local translations = useNotApprovedPageContext().translations;
            local beginDate = p8324.moderationDetail.beginDate;

            return u8307.createElement(View, {
                tag = "size-full-0 auto-y col gap-small",
                LayoutOrder = 1
            }, {
                BadUtterancesContent = u8307.createElement(BadUtterancesContent, {
                    LayoutOrder = 1,
                    badUtterances = p8324.moderationDetail.badUtterances
                }),
                Divider = u8307.createElement(View, {
                    tag = "auto-xy padding-y-small",
                    LayoutOrder = 2
                }, {
                    Divider = u8307.createElement(Divider, nil)
                }),
                ReviewDate = u8307.createElement(u8304, {
                    layoutOrder = 4,
                    fieldLabel = translations.dateReviewedLabel,
                    fieldValue = u8306(beginDate, translations)
                })
            });
        end)
    };
end;

function u2.fPF() -- Line: 56891
    -- upvalues: u2 (ref)
    local VERIFICATION_TYPES = u2.loadModule("fPa").Constants.VERIFICATION_TYPES;
    u2.loadModule("fPc");
    u2.loadModule("fPj");
    local u8325 = u2.loadModule("fPf");
    local v8326 = u2.loadModule("fPg");
    local Text = v8326.Text;
    local View = v8326.View;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return {
        getIsVisible = function(p8327) -- Line: 56940, Name: getIsVisible
            -- upvalues: VERIFICATION_TYPES (copy)
            local verificationCategory = p8327.verificationCategory;

            return verificationCategory == VERIFICATION_TYPES.Parent and true or verificationCategory == VERIFICATION_TYPES.Email;
        end,

        renderComponent = u8325.memo(function(p8328) -- Line: 56913, Name: ChargebackSteps
            -- upvalues: useNotApprovedPageContext (copy), VERIFICATION_TYPES (copy), u8325 (copy), View (copy), Text (copy)
            local translations = useNotApprovedPageContext().translations;
            local v8329;

            if p8328.moderationDetail.verificationCategory == VERIFICATION_TYPES.Parent then
                v8329 = translations.parentReactivationNotice;
            else
                v8329 = translations.emailReactivationNotice;
            end;

            return u8325.createElement(View, {
                tag = "size-full-0 auto-y col gap-medium",
                LayoutOrder = p8328.layoutOrder
            }, {
                Heading = u8325.createElement(Text, {
                    tag = "auto-xy text-heading-medium text-align-x-left text-wrap content-emphasis",
                    LayoutOrder = 1,
                    Text = translations.chargebackNextSteps
                }),
                Content = u8325.createElement(Text, {
                    tag = "auto-xy text-align-x-left text-wrap text-body-large",
                    LayoutOrder = 2,
                    Text = v8329
                })
            });
        end)
    };
end;

function u2.fPR() -- Line: 57133
    return __DefineFastFlag("EnableNapNewWebView", false);
end;

function u2.fPG() -- Line: 57201
    -- upvalues: u2 (ref)
    local u8350 = u2.loadModule("fPk");
    u2.loadModule("fPc");
    local Constants = u2.loadModule("fPa").Constants;
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local EVENT_TYPES = Constants.EVENT_TYPES;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;
    local u8351 = u2.loadModule("fPf");
    local AppPage = u2.loadModule("fPH").AppPage;
    local NavigateDown = u2.loadModule("fPI").Thunks.NavigateDown;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local useCallback = u8351.useCallback;
    local FFlagSignalsNavP3Dispatch = u2.loadModule("fPq").FFlagSignalsNavP3Dispatch;
    local u8352;

    if FFlagSignalsNavP3Dispatch then
        u8352 = u2.loadModule("fPK").NavigationCommands;
    else
        u8352 = nil;
    end;

    local v8353 = u2.loadModule("fPg");
    local Text = v8353.Text;
    local View = v8353.View;
    local Button = v8353.Button;
    local ButtonVariant = v8353.Enums.ButtonVariant;
    local InputSize = v8353.Enums.InputSize;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8354 = u2.loadModule("fPL");
    u2.loadModule("fPj");
    local u8355 = u2.loadModule("fPR");

    return {
        getIsVisible = function(p8356) -- Line: 57346, Name: getIsVisible
            -- upvalues: PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), INTERVENTION_TYPES (copy)
            return PUNISHMENT_TYPE_TO_INTERVENTION_MAP[p8356.punishmentTypeDescription] ~= INTERVENTION_TYPES.Deleted;
        end,

        renderComponent = u8351.memo(function(p8357) -- Line: 57245, Name: PreventionSteps
            -- upvalues: useNotApprovedPageContext (copy), u8355 (copy), u8354 (copy), UrlBuilder (copy), useCallback (copy), u8350 (copy), EVENT_TYPES (copy), AppPage (copy), FFlagSignalsNavP3Dispatch (copy), u8352 (copy), NavigateDown (copy), u8351 (copy), View (copy), Text (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
            local v8358 = useNotApprovedPageContext();
            local translations = v8358.translations;
            local isKidsTreatment = v8358.isKidsTreatment;
            local dispatch = p8357.dispatch;
            local hasEducationalPages = p8357.hasEducationalPages;
            local showUGCAvatarGuidelinesLink = p8357.moderationDetail.showUGCAvatarGuidelinesLink;
            local isAltInformed = p8357.moderationDetail.isAltInformed;
            local u8359;

            if u8355 then
                local v8360;

                if showUGCAvatarGuidelinesLink then
                    v8360 = UrlBuilder.static.creatorHub() .. "/docs/marketplace/marketplace-policy#general-creation-guidelines";
                else
                    v8360 = UrlBuilder.static.about.guidelines();
                end;

                local v8361;

                if showUGCAvatarGuidelinesLink then
                    v8361 = translations.avatarGuidelinesLabel;
                else
                    v8361 = translations.communityStandardsLabel;
                end;

                u8359 = u8354(v8360, v8361);
            else
                u8359 = nil;
            end;

            local v8368 = useCallback(function() -- Line: 57266
                -- upvalues: u8350 (ref), showUGCAvatarGuidelinesLink (copy), EVENT_TYPES (ref), u8355 (ref), u8359 (copy), AppPage (ref), UrlBuilder (ref), translations (copy), FFlagSignalsNavP3Dispatch (ref), u8352 (ref), dispatch (copy), NavigateDown (ref)
                local v8362 = {};
                local v8363;

                if showUGCAvatarGuidelinesLink then
                    v8363 = EVENT_TYPES.UGCGuidelinesClicked;
                else
                    v8363 = EVENT_TYPES.CommunityGuidelineClicked;
                end;

                v8362.eventType = v8363;
                u8350(v8362);

                if u8355 and u8359 then
                    u8359();

                    return;
                end;

                local v8364 = {
                    name = AppPage.GenericWebPage
                };
                local v8365;

                if showUGCAvatarGuidelinesLink then
                    v8365 = UrlBuilder.static.creatorHub() .. "/docs/marketplace/marketplace-policy#general-creation-guidelines";
                else
                    v8365 = UrlBuilder.static.about.guidelines();
                end;

                v8364.detail = v8365;
                local v8366 = {};
                local v8367;

                if showUGCAvatarGuidelinesLink then
                    v8367 = translations.avatarGuidelinesLabel;
                else
                    v8367 = translations.communityStandardsLabel;
                end;

                v8366.title = v8367;
                v8364.extraProps = v8366;

                if FFlagSignalsNavP3Dispatch then
                    u8352.down(u8352.fromLegacyPage(v8364));

                    return;
                end;

                dispatch(NavigateDown(v8364));
            end, {
                dispatch,
                u8359,
                showUGCAvatarGuidelinesLink,
                translations.avatarGuidelinesLabel,
                translations.communityStandardsLabel
            });
            local createElement = u8351.createElement;
            local v8369 = {
                tag = "col gap-medium size-full-0 auto-y",
                LayoutOrder = p8357.layoutOrder
            };
            local v8370 = {};
            local createElement2 = u8351.createElement;
            local v8371 = {
                tag = "auto-xy text-heading-medium text-wrap text-align-x-left content-emphasis",
                LayoutOrder = 1
            };
            local v8372;

            if isKidsTreatment then
                v8372 = translations.preventionStepsHeadingKids;
            else
                v8372 = translations.preventionStepsHeading;
            end;

            v8371.Text = v8372;
            v8370.Heading = createElement2(Text, v8371);
            local createElement3 = u8351.createElement;
            local v8373 = {
                tag = "col gap-medium size-full-0 auto-y",
                LayoutOrder = 3
            };
            local v8374 = {};
            local createElement4 = u8351.createElement;
            local v8375 = {
                tag = "auto-xy text-body-large text-wrap text-align-x-left",
                LayoutOrder = 3
            };
            local v8376;

            if isKidsTreatment then
                v8376 = translations.foreshadowDescriptionKids;
            else
                v8376 = translations.foreshadowDescription;
            end;

            v8375.Text = v8376;
            v8374.Description = createElement4(Text, v8375);

            if isAltInformed then
                isAltInformed = u8351.createElement(Text, {
                    tag = "auto-xy text-body-large text-wrap text-align-x-left",
                    LayoutOrder = 4,
                    Text = translations.linkedAccountsDescription
                });
            end;

            v8374.LinkedAccountsDescription = isAltInformed;

            if not hasEducationalPages or showUGCAvatarGuidelinesLink then
                local createElement5 = u8351.createElement;
                local v8377 = {
                    LayoutOrder = 5
                };
                local v8378;

                if showUGCAvatarGuidelinesLink then
                    v8378 = translations.avatarGuidelinesLabel;
                else
                    v8378 = translations.viewRulesButton;
                end;

                v8377.text = v8378;
                v8377.onActivated = v8368;
                v8377.variant = ButtonVariant.Standard;
                v8377.size = InputSize.Small;
                v8377.width = UDim.new(1, 0);
                showUGCAvatarGuidelinesLink = createElement5(Button, v8377);
            end;

            v8374.GuidelinesLink = showUGCAvatarGuidelinesLink;
            v8370.Content = createElement3(View, v8373, v8374);

            return createElement(View, v8369, v8370);
        end)
    };
end;

function u2.fPT() -- Line: 57356
    -- upvalues: u2 (ref)
    local LocalizationService = game:GetService("LocalizationService");
    local Constants = u2.loadModule("fPa").Constants;
    local Localization = u2.loadModule("fPp").Localization;
    local u8379 = u2.loadModule("fPz");
    u2.loadModule("fPc");
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local u8380 = Localization.new(LocalizationService.RobloxLocaleId);

    return function(p8381) -- Line: 57376, Name: determinePunishmentDescription
        -- upvalues: INTERVENTION_TYPES (copy), u8380 (copy), u8379 (copy)
        if p8381.isKidsTreatment then
            if p8381.interventionType == INTERVENTION_TYPES.Warning then
                return u8380:Format("Feature.NotApproved.Description.WarningDescription.Kids");
            end;

            if p8381.interventionType == INTERVENTION_TYPES.Banned then
                if DateTime.fromIsoDate(p8381.endDate) then
                    return u8380:Format("Feature.NotApproved.Description.SuspendedUntil", {
                        date = u8379(p8381.endDate, p8381.translations, "LL"),
                        time = u8379(p8381.endDate, p8381.translations, "LT")
                    });
                end;
            elseif p8381.interventionType == INTERVENTION_TYPES.Deleted then
                return u8380:Format("Feature.NotApproved.Description.BannedDescription.Kids");
            end;
        end;

        if p8381.interventionType == INTERVENTION_TYPES.Deleted then
            return u8380:Format("Feature.NotApproved.Description.BrokeRulesBanned");
        end;

        if #p8381.violationReasons > 0 then
            if p8381.violationType and p8381.violationType ~= "" then
                return u8380:Format("Feature.NotApproved.Description.BrokeRulesTypePolicy.V2", {
                    type = p8381.violationType,
                    policy = string.lower(table.concat(p8381.violationReasons, ", "))
                });
            end;

            return u8380:Format("Feature.NotApproved.Description.BrokeRulesPolicy.V2", {
                policy = string.lower(table.concat(p8381.violationReasons, ", "))
            });
        end;

        if p8381.violationType and p8381.violationType ~= "" then
            return u8380:Format("Feature.NotApproved.Description.BrokeRulesType", {
                type = p8381.violationType
            });
        end;

        return u8380:Format("Feature.NotApproved.Description.BrokeRulesGeneric");
    end;
end;

function u2.fPS() -- Line: 57421
    -- upvalues: u2 (ref)
    local Constants = u2.loadModule("fPa").Constants;
    local u8382 = u2.loadModule("fPT");
    u2.loadModule("fPj");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8383 = u2.loadModule("fPf");
    local v8384 = u2.loadModule("fPg");
    local View = v8384.View;
    local Text = v8384.Text;
    local useMemo = u8383.useMemo;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;

    return {
        getIsVisible = function() -- Line: 57484, Name: getIsVisible
            return true;
        end,

        renderComponent = u8383.memo(function(u8385) -- Line: 57442, Name: PunishmentDescription
            -- upvalues: useNotApprovedPageContext (copy), PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), useMemo (copy), u8382 (copy), u8383 (copy), View (copy), Text (copy)
            local v8386 = useNotApprovedPageContext();
            local translations = v8386.translations;
            local translatedReasons = v8386.violationReasons.translatedReasons;
            local isKidsTreatment = v8386.isKidsTreatment;
            local u8387 = PUNISHMENT_TYPE_TO_INTERVENTION_MAP[u8385.moderationDetail.punishmentTypeDescription];
            local v8388 = useMemo(function() -- Line: 57452
                -- upvalues: u8382 (ref), translations (copy), u8387 (copy), translatedReasons (copy), isKidsTreatment (copy), u8385 (copy)
                return u8382({
                    violationType = translations.violationType,
                    interventionType = u8387,
                    violationReasons = translatedReasons or {},
                    isKidsTreatment = isKidsTreatment,
                    endDate = u8385.moderationDetail.endDate,
                    translations = translations
                });
            end, {
                translations.violationType,
                translations,
                u8387,
                translatedReasons,
                isKidsTreatment,
                u8385.moderationDetail.endDate
            });

            return u8383.createElement(View, {
                tag = "col gap-small size-full-0 auto-y",
                testId = "punishment-description",
                LayoutOrder = u8385.layoutOrder
            }, {
                Description = u8383.createElement(Text, {
                    tag = "auto-xy text-body-medium text-wrap text-align-x-left content-emphasis",
                    LayoutOrder = 1,
                    Text = v8388
                })
            });
        end)
    };
end;

function u2.fPV() -- Line: 57493
    -- upvalues: u2 (ref)
    local HttpService = game:GetService("HttpService");
    local u8389 = u2.loadModule("fPv");
    local u8390 = u2.loadModule("fPw");
    local u8391 = u2.loadModule("fPz");
    local u8392 = u2.loadModule("fPk");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    u2.loadModule("fPc");
    local u8393 = u2.loadModule("fPf");
    local useMemo = u8393.useMemo;
    local View = u2.loadModule("fPg").View;
    u2.loadModule("fPj");
    local Constants = u2.loadModule("fPa").Constants;
    local u8394 = u2.loadModule("fPy");

    return {
        getIsVisible = function(p8395) -- Line: 57609, Name: getIsVisible
            -- upvalues: u8390 (copy)
            return u8390.isVisibleInView(p8395.violation);
        end,

        renderComponent = u8393.memo(function(p8396) -- Line: 57529, Name: ViolationEvidence
            -- upvalues: useNotApprovedPageContext (copy), useMemo (copy), u8390 (copy), u8394 (copy), u8392 (copy), Constants (copy), HttpService (copy), u8393 (copy), u8389 (copy), View (copy), u8391 (copy)
            local translations = useNotApprovedPageContext().translations;
            local violation = p8396.moderationDetail.violation;
            local beginDate = p8396.moderationDetail.beginDate;

            if not violation then
                return nil;
            end;

            local u8397 = useMemo(function() -- Line: 57543
                -- upvalues: u8390 (ref), violation (copy)
                return u8390.filterForVisibleElements(violation.evidence.elements);
            end, { violation.evidence.elements });
            local v8400 = useMemo(function() -- Line: 57547
                -- upvalues: u8397 (copy), u8394 (ref), translations (copy), u8392 (ref), Constants (ref), HttpService (ref), u8393 (ref), u8389 (ref)
                local v8398 = {};

                for i, v in u8397 do
                    if v.type == "text" then
                        local text = v.text;

                        if u8394 and v.textKey then
                            text = translations[v.textKey .. "_" .. v.labelKey];

                            if not text or text == "" then
                                u8392({
                                    eventType = Constants.EVENT_TYPES.MissingTranslation,
                                    additionalInfo = HttpService:JSONEncode({
                                        key = v.textKey,
                                        params = v.textKeyParameters
                                    })
                                });
                                text = v.textKey;
                            end;
                        end;

                        local createElement = u8393.createElement;
                        local v8399 = {
                            fieldLabel = translations[v.labelKey]
                        };

                        if not u8394 then
                            text = v.text;
                        end;

                        v8399.fieldValue = text;
                        v8399.layoutOrder = i;
                        table.insert(v8398, createElement(u8389, v8399));
                    end;
                end;

                return v8398;
            end, { u8397 });

            return u8393.createElement(View, {
                tag = "size-full-0 auto-y col gap-small",
                LayoutOrder = 1
            }, {
                Elements = u8393.createElement(View, {
                    tag = "size-full-0 auto-y col gap-small",
                    LayoutOrder = 2
                }, unpack(v8400)),
                ReviewDate = u8393.createElement(u8389, {
                    layoutOrder = 3,
                    fieldLabel = translations.dateReviewedLabel,
                    fieldValue = u8391(beginDate, translations)
                })
            });
        end)
    };
end;

function u2.fPW() -- Line: 57618
    -- upvalues: u2 (ref)
    local u8401 = u2.loadModule("fPv");
    local u8402 = u2.loadModule("fPw");
    local u8403 = u2.loadModule("fPz");
    u2.loadModule("fPc");
    u2.loadModule("fPj");
    local u8404 = u2.loadModule("fPf");
    local View = u2.loadModule("fPg").View;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return {
        getIsVisible = function(p8405) -- Line: 57658, Name: getIsVisible
            -- upvalues: u8402 (copy)
            local badUtterances = p8405.badUtterances;
            local v8406 = not u8402.isVisibleInView(p8405.violation) and (not badUtterances or #badUtterances == 0);

            return v8406;
        end,

        renderComponent = u8404.memo(function(p8407) -- Line: 57641, Name: SimpleModeratorNote
            -- upvalues: useNotApprovedPageContext (copy), u8404 (copy), View (copy), u8401 (copy), u8403 (copy)
            local translations = useNotApprovedPageContext().translations;

            return u8404.createElement(View, {
                tag = "size-full-0 auto-y col gap-small",
                LayoutOrder = p8407.layoutOrder
            }, {
                ReviewDate = u8404.createElement(u8401, {
                    layoutOrder = 2,
                    fieldLabel = translations.dateReviewedLabel,
                    fieldValue = u8403(p8407.moderationDetail.beginDate, translations)
                })
            });
        end)
    };
end;

function u2.fPU() -- Line: 57669
    -- upvalues: u2 (ref)
    local u8408 = u2.loadModule("fPk");
    local EVENT_TYPES = u2.loadModule("fPa").Constants.EVENT_TYPES;
    local u8409 = u2.loadModule("fPf");
    local useCallback = u8409.useCallback;
    local AppPage = u2.loadModule("fPH").AppPage;
    local NavigateDown = u2.loadModule("fPI").Thunks.NavigateDown;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local FFlagSignalsNavP3Dispatch = u2.loadModule("fPq").FFlagSignalsNavP3Dispatch;
    local u8410;

    if FFlagSignalsNavP3Dispatch then
        u8410 = u2.loadModule("fPK").NavigationCommands;
    else
        u8410 = nil;
    end;

    local v8411 = u2.loadModule("fPg");
    local Text = v8411.Text;
    local View = v8411.View;
    local Button = v8411.Button;
    local ButtonVariant = v8411.Enums.ButtonVariant;
    local InputSize = v8411.Enums.InputSize;
    local renderPageItemsFromList = u2.loadModule("fPj").renderPageItemsFromList;
    local v8412 = u2.loadModule("fPV");
    local v8413 = u2.loadModule("fPu");
    local v8414 = u2.loadModule("fPW");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8415 = u2.loadModule("fPL");
    local FFlagNavigateToSafetyDashboardForAppeals = u2.loadModule("fPq").FFlagNavigateToSafetyDashboardForAppeals;
    local u8416 = u2.loadModule("fPR");
    local u8417 = { v8412, v8413, v8414 };

    return {
        getIsVisible = function() -- Line: 57821, Name: getIsVisible
            return true;
        end,

        renderComponent = u8409.memo(function(p8418) -- Line: 57719, Name: RecentActivity
            -- upvalues: useNotApprovedPageContext (copy), FFlagNavigateToSafetyDashboardForAppeals (copy), UrlBuilder (copy), u8416 (copy), u8415 (copy), renderPageItemsFromList (copy), u8417 (copy), useCallback (copy), u8408 (copy), EVENT_TYPES (copy), AppPage (copy), FFlagSignalsNavP3Dispatch (copy), u8410 (copy), NavigateDown (copy), u8409 (copy), View (copy), Text (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
            local v8419 = useNotApprovedPageContext();
            local translations = v8419.translations;
            local isKidsTreatment = v8419.isKidsTreatment;
            local u8420;

            if FFlagNavigateToSafetyDashboardForAppeals then
                u8420 = UrlBuilder.static.safetyDashboard.violations();
            else
                u8420 = UrlBuilder.static.appealsPortal.main();
            end;

            local u8421;

            if u8416 then
                local v8422;

                if FFlagNavigateToSafetyDashboardForAppeals then
                    v8422 = translations.accountStatusTitle;
                else
                    v8422 = translations.appealsPortalTitle;
                end;

                u8421 = u8415(u8420, v8422);
            else
                u8421 = nil;
            end;

            local interventionId = p8418.moderationDetail.interventionId;
            local consequenceTransparencyMessage = p8418.moderationDetail.consequenceTransparencyMessage;
            local dispatch = p8418.dispatch;
            local v8423 = renderPageItemsFromList(u8417, p8418.moderationDetail, p8418.dispatch);
            local v8427 = useCallback(function() -- Line: 57744
                -- upvalues: u8408 (ref), EVENT_TYPES (ref), u8416 (ref), u8421 (copy), AppPage (ref), u8420 (copy), FFlagNavigateToSafetyDashboardForAppeals (ref), translations (copy), FFlagSignalsNavP3Dispatch (ref), u8410 (ref), dispatch (copy), NavigateDown (ref)
                u8408({
                    eventType = EVENT_TYPES.AppealsPortalClicked
                });

                if u8416 and u8421 then
                    u8421();

                    return;
                end;

                local v8424 = {
                    name = AppPage.GenericWebPage,
                    detail = u8420
                };
                local v8425 = {};
                local v8426;

                if FFlagNavigateToSafetyDashboardForAppeals then
                    v8426 = translations.accountStatusTitle;
                else
                    v8426 = translations.appealsPortalTitle;
                end;

                v8425.title = v8426;
                v8424.extraProps = v8425;

                if FFlagSignalsNavP3Dispatch then
                    u8410.down(u8410.fromLegacyPage(v8424));

                    return;
                end;

                dispatch(NavigateDown(v8424));
            end, {
                u8420,
                dispatch,
                u8421,
                translations
            });
            local createElement = u8409.createElement;
            local v8428 = {
                tag = "col gap-medium size-full-0 auto-y",
                LayoutOrder = p8418.layoutOrder
            };
            local v8429 = {};
            local createElement2 = u8409.createElement;
            local v8430 = {
                tag = "auto-xy text-title-large text-wrap text-align-x-left content-emphasis",
                LayoutOrder = 1
            };
            local v8431;

            if isKidsTreatment then
                v8431 = translations.latestActivityLabelKids;
            else
                v8431 = translations.latestActivityLabel;
            end;

            v8430.Text = v8431;
            v8429.Heading = createElement2(Text, v8430);
            local createElement3 = u8409.createElement;
            local v8432 = {
                tag = "col gap-xsmall size-full-0 auto-y",
                LayoutOrder = 2
            };
            local v8433 = {};
            local createElement4 = u8409.createElement;
            local v8434 = {
                tag = "col gap-small size-full-0 auto-y padding-large radius-medium bg-shift-100",
                LayoutOrder = 1
            };
            local v8435 = {
                Evidence = u8409.createElement(View, {
                    tag = "col size-full-0 auto-y",
                    LayoutOrder = 1
                }, unpack(v8423))
            };
            local v8436;

            if consequenceTransparencyMessage == "" then
                v8436 = false;
            else
                v8436 = u8409.createElement(Text, {
                    tag = "auto-xy text-body-medium text-wrap text-align-x-left",
                    RichText = true,
                    LayoutOrder = 2,
                    Text = `<b>{translations.decisionMethodLabel}:</b>\n{consequenceTransparencyMessage}`
                });
            end;

            v8435.DecisionMethod = v8436;
            v8435.ViewActivityButton = u8409.createElement(Button, {
                LayoutOrder = 3,
                text = translations.viewMoreButton,
                onActivated = v8427,
                variant = ButtonVariant.Standard,
                size = InputSize.Small,
                width = UDim.new(1, 0)
            });
            v8433.EvidenceCard = createElement4(View, v8434, v8435);
            v8433.InterventionId = u8409.createElement(Text, {
                tag = "auto-xy text-caption-medium text-wrap text-align-x-left content-muted",
                LayoutOrder = 2,
                Text = interventionId
            });
            v8429.Content = createElement3(View, v8432, v8433);

            return createElement(View, v8428, v8429);
        end)
    };
end;

function u2.fPY() -- Line: 57830
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;

    return function(p8437) -- Line: 57840, Name: getSafetyDashboardAppealUrl
        -- upvalues: UrlBuilder (copy)
        if p8437 and p8437.uid ~= "" then
            return UrlBuilder.static.safetyDashboard.violation({
                id = p8437.uid
            });
        end;

        return UrlBuilder.static.safetyDashboard.violations();
    end;
end;

function u2.fPX() -- Line: 57851
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local EVENT_TYPES = u2.loadModule("fPa").Constants.EVENT_TYPES;
    local u8438 = u2.loadModule("fPf");
    local useCallback = u8438.useCallback;
    local AppPage = u2.loadModule("fPH").AppPage;
    local NavigateDown = u2.loadModule("fPI").Thunks.NavigateDown;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local FFlagSignalsNavP3Dispatch = u2.loadModule("fPq").FFlagSignalsNavP3Dispatch;
    local u8439;

    if FFlagSignalsNavP3Dispatch then
        u8439 = u2.loadModule("fPK").NavigationCommands;
    else
        u8439 = nil;
    end;

    local v8440 = u2.loadModule("fPg");
    local Text = v8440.Text;
    local View = v8440.View;
    local Button = v8440.Button;
    local ButtonVariant = v8440.Enums.ButtonVariant;
    local InputSize = v8440.Enums.InputSize;
    local u8441 = u2.loadModule("fPY");
    local u8442 = u2.loadModule("fPk");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8443 = u2.loadModule("fPL");
    local STATIC_PAGE_NAMES = u2.loadModule("fPj").STATIC_PAGE_NAMES;
    local FFlagNavigateToSafetyDashboardForAppeals = u2.loadModule("fPq").FFlagNavigateToSafetyDashboardForAppeals;
    local u8444 = u2.loadModule("fPR");

    return {
        getIsVisible = function(p8445, p8446, p8447, p8448) -- Line: 57962, Name: getIsVisible
            -- upvalues: STATIC_PAGE_NAMES (copy)
            local v8449;

            if p8448 then
                v8449 = p8448.educational_pass_eligible;
            else
                v8449 = false;
            end;

            return (p8447 or STATIC_PAGE_NAMES.Unknown) == STATIC_PAGE_NAMES.SecondChanceIntro and true or not v8449;
        end,

        renderComponent = u8438.memo(function(p8450) -- Line: 57896, Name: ReportMistake
            -- upvalues: useNotApprovedPageContext (copy), FFlagNavigateToSafetyDashboardForAppeals (copy), u8441 (copy), UrlBuilder (copy), u8444 (copy), u8443 (copy), useCallback (copy), u8442 (copy), EVENT_TYPES (copy), AppPage (copy), FFlagSignalsNavP3Dispatch (copy), u8439 (copy), NavigateDown (copy), u8438 (copy), View (copy), Text (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
            local v8451 = useNotApprovedPageContext();
            local translations = v8451.translations;
            local isKidsTreatment = v8451.isKidsTreatment;
            local dispatch = p8450.dispatch;
            local violation = p8450.moderationDetail.violation;
            local u8452;

            if FFlagNavigateToSafetyDashboardForAppeals then
                u8452 = u8441(violation);
            else
                u8452 = UrlBuilder.static.appealsPortal.main();
            end;

            local u8453;

            if u8444 then
                local v8454;

                if FFlagNavigateToSafetyDashboardForAppeals then
                    v8454 = translations.accountStatusTitle;
                else
                    v8454 = translations.appealsPortalTitle;
                end;

                u8453 = u8443(u8452, v8454);
            else
                u8453 = nil;
            end;

            local v8458 = useCallback(function() -- Line: 57916
                -- upvalues: u8442 (ref), EVENT_TYPES (ref), u8444 (ref), u8453 (copy), AppPage (ref), u8452 (copy), FFlagNavigateToSafetyDashboardForAppeals (ref), translations (copy), FFlagSignalsNavP3Dispatch (ref), u8439 (ref), dispatch (copy), NavigateDown (ref)
                u8442({
                    eventType = EVENT_TYPES.AppealsPortalClicked
                });

                if u8444 and u8453 then
                    u8453();

                    return;
                end;

                local v8455 = {
                    name = AppPage.GenericWebPage,
                    detail = u8452
                };
                local v8456 = {};
                local v8457;

                if FFlagNavigateToSafetyDashboardForAppeals then
                    v8457 = translations.accountStatusTitle;
                else
                    v8457 = translations.appealsPortalTitle;
                end;

                v8456.title = v8457;
                v8455.extraProps = v8456;

                if FFlagSignalsNavP3Dispatch then
                    u8439.down(u8439.fromLegacyPage(v8455));

                    return;
                end;

                dispatch(NavigateDown(v8455));
            end, {
                u8452,
                dispatch,
                u8453,
                translations
            });
            local createElement = u8438.createElement;
            local v8459 = {
                tag = "col gap-medium size-full-0 auto-y",
                LayoutOrder = p8450.layoutOrder
            };
            local v8460 = {};
            local createElement2 = u8438.createElement;
            local v8461 = {
                tag = "auto-xy text-body-large text-wrap text-align-x-left",
                LayoutOrder = 2
            };
            local v8462;

            if isKidsTreatment then
                v8462 = translations.reportMistakeDescriptionKids;
            else
                v8462 = translations.reportMistakeDescriptionV3;
            end;

            v8461.Text = v8462;
            v8460.Content = createElement2(Text, v8461);
            v8460.ReportMistakeButton = u8438.createElement(Button, {
                LayoutOrder = 3,
                text = translations.sendAppealButton,
                onActivated = v8458,
                variant = ButtonVariant.Standard,
                size = InputSize.Small,
                width = UDim.new(1, 0)
            });

            return createElement(View, v8459, v8460);
        end)
    };
end;

function u2.fPZ() -- Line: 57980
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8463 = u2.loadModule("fPf");
    local v8464 = u2.loadModule("fPg");
    local Text = v8464.Text;
    local View = v8464.View;
    u2.loadModule("fPj");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return {
        getIsVisible = function(p8465, p8466) -- Line: 58022, Name: getIsVisible
            return true;
        end,

        renderComponent = u8463.memo(function(p8467) -- Line: 58000, Name: SecondChanceConclusion
            -- upvalues: useNotApprovedPageContext (copy), u8463 (copy), View (copy), Text (copy)
            local translations = useNotApprovedPageContext().translations;

            return u8463.createElement(View, {
                tag = "col size-full-0 auto-y gap-medium",
                LayoutOrder = p8467.layoutOrder
            }, {
                Heading = u8463.createElement(Text, {
                    tag = "auto-xy text-heading-medium content-emphasis text-align-x-left text-wrap",
                    LayoutOrder = 1,
                    Text = translations.secondChanceConclusionHeading
                }),
                Description = u8463.createElement(Text, {
                    tag = "auto-xy text-body-large text-align-x-left text-wrap",
                    LayoutOrder = 2,
                    Text = translations.secondChanceConclusionDescription
                })
            });
        end)
    };
end;

function u2.fQa() -- Line: 58031
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8468 = u2.loadModule("fPf");
    local v8469 = u2.loadModule("fPg");
    local Text = v8469.Text;
    local View = v8469.View;
    u2.loadModule("fPj");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return {
        getIsVisible = function(p8470, p8471) -- Line: 58073, Name: getIsVisible
            return true;
        end,

        renderComponent = u8468.memo(function(p8472) -- Line: 58051, Name: SecondChanceIntro
            -- upvalues: useNotApprovedPageContext (copy), u8468 (copy), View (copy), Text (copy)
            local translations = useNotApprovedPageContext().translations;

            return u8468.createElement(View, {
                tag = "col size-full-0 auto-y gap-large",
                LayoutOrder = p8472.layoutOrder
            }, {
                Heading = u8468.createElement(Text, {
                    tag = "auto-xy text-heading-medium content-emphasis text-align-x-left text-wrap",
                    LayoutOrder = 1,
                    Text = translations.secondChanceIntroHeading
                }),
                Description = u8468.createElement(Text, {
                    tag = "auto-xy text-body-large text-align-x-left text-wrap",
                    LayoutOrder = 2,
                    Text = translations.secondChanceIntroDescription
                })
            });
        end)
    };
end;

function u2.fQb() -- Line: 58082
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    u2.loadModule("fPj");
    local u8473 = u2.loadModule("fPf");
    local v8474 = u2.loadModule("fPg");
    local Text = v8474.Text;
    local View = v8474.View;
    local useMemo = u8473.useMemo;
    local u8475 = u2.loadModule("fPv");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return {
        getIsVisible = function() -- Line: 58152, Name: getIsVisible
            return true;
        end,

        renderComponent = u8473.memo(function(p8476) -- Line: 58103, Name: WhatHappened
            -- upvalues: useNotApprovedPageContext (copy), useMemo (copy), u8473 (copy), View (copy), Text (copy), u8475 (copy)
            local v8477 = useNotApprovedPageContext();
            local translations = v8477.translations;
            local violationReasons = v8477.violationReasons;
            local isKidsTreatment = v8477.isKidsTreatment;
            local moderatorNote = v8477.moderatorNote;
            local v8478 = useMemo(function() -- Line: 58110
                -- upvalues: violationReasons (copy), translations (copy)
                local table_concat_ret = table.concat(violationReasons.translatedReasons, ", ");

                if table_concat_ret == "" then
                    return translations.otherAbuseType;
                end;

                return table_concat_ret;
            end, { violationReasons.translatedReasons, translations.otherAbuseType });
            local createElement = u8473.createElement;
            local v8479 = {
                tag = "col gap-medium size-full-0 auto-y",
                LayoutOrder = p8476.layoutOrder
            };
            local v8480 = {};
            local createElement2 = u8473.createElement;
            local v8481 = {
                tag = "auto-xy text-title-large text-wrap text-align-x-left content-emphasis",
                LayoutOrder = 1
            };
            local v8482;

            if isKidsTreatment then
                v8482 = translations.whatHappenedLabelKids;
            else
                v8482 = translations.whatHappenedLabel;
            end;

            v8481.Text = v8482;
            v8480.Heading = createElement2(Text, v8481);
            local createElement3 = u8473.createElement;
            local v8483 = {
                tag = "col gap-small size-full-0 auto-y padding-large radius-medium bg-shift-100",
                LayoutOrder = 2
            };
            local v8484 = {};
            local v8485;

            if isKidsTreatment then
                v8485 = u8473.createElement(u8475, {
                    layoutOrder = 1,
                    showColon = false,
                    fieldLabel = v8478,
                    fieldValue = moderatorNote
                });
            else
                v8485 = u8473.createElement(u8475, {
                    layoutOrder = 1,
                    fieldLabel = translations.reasonLabel,
                    fieldValue = v8478
                });
            end;

            v8484.Reason = v8485;
            local v8486 = not isKidsTreatment and u8473.createElement(u8475, {
                layoutOrder = 2,
                fieldLabel = translations.moderatorNoteLabel,
                fieldValue = moderatorNote
            });
            v8484.ModeratorNote = v8486;
            v8480.Content = createElement3(View, v8483, v8484);

            return createElement(View, v8479, v8480);
        end)
    };
end;

function u2.fQg() -- Line: 58199
    local CoreGui = game:GetService("CoreGui");

    return function() -- Line: 58203, Name: getVRSurfaceGui
        -- upvalues: CoreGui (copy)
        local LuaAppScreenGui = CoreGui:FindFirstChild("LuaAppScreenGui");
        local v8487;

        if LuaAppScreenGui then
            v8487 = LuaAppScreenGui:FindFirstChild("MainAppScreen_SurfaceGui");
        else
            v8487 = nil;
        end;

        if v8487 and v8487:IsA("SurfaceGui") then
            return v8487;
        end;

        return nil;
    end;
end;

function u2.fQh() -- Line: 58219
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");

    return function(p8488) -- Line: 58226, Name: hasAnyCommutation
        if not p8488 then
            return false;
        end;

        for _, v in p8488 do
            if v == true then
                return true;
            end;
        end;

        return false;
    end;
end;

function u2.fQd() -- Line: 58252
    -- upvalues: u2 (ref)
    local VRService = game:GetService("VRService");
    local u8489 = u2.loadModule("fPf");
    local useCallback = u8489.useCallback;
    local useEffect = u8489.useEffect;
    local useRef = u8489.useRef;
    local useState = u8489.useState;
    local useMemo = u8489.useMemo;
    local v8490 = u2.loadModule("fPg");
    local Coachmark = v8490.Coachmark;
    local OverlayProvider = v8490.OverlayProvider;
    local PopoverSide = v8490.Enums.PopoverSide;
    local PopoverAlign = v8490.Enums.PopoverAlign;
    local v8491 = u2.loadModule("fQe");
    local FocusNavigableSurfaceIdentifierEnum = v8491.FocusNavigableSurfaceIdentifierEnum;
    local FocusNavigationEventNameEnum = v8491.FocusNavigationEventNameEnum;
    u2.loadModule("fQf");
    local useAppFocusRoot = v8491.useAppFocusRoot;
    local Constants = u2.loadModule("fPa").Constants;
    local u8492 = u2.loadModule("fOZ");
    local u8493 = u2.loadModule("fQg");
    local u8494 = u2.loadModule("fQh");
    local u8495 = u2.loadModule("fQi");
    u2.loadModule("fPc");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;

    return u8489.memo(function(p8496) -- Line: 58291, Name: ReactivationCoachmark
        -- upvalues: useRef (copy), useState (copy), useNotApprovedPageContext (copy), VRService (copy), u8493 (copy), PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), u8492 (copy), u8494 (copy), useCallback (copy), useMemo (copy), FocusNavigationEventNameEnum (copy), u8495 (copy), useAppFocusRoot (copy), FocusNavigableSurfaceIdentifierEnum (copy), useEffect (copy), u8489 (copy), OverlayProvider (copy), Coachmark (copy), PopoverSide (copy), PopoverAlign (copy)
        local u8497 = useRef(nil);
        local v8498, u8499 = useState(false);
        local v8500 = useNotApprovedPageContext();
        local translations = v8500.translations;
        local commutationEligibility = v8500.commutationEligibility;
        local v8501;

        if VRService.VREnabled then
            v8501 = u8493();
        else
            v8501 = nil;
        end;

        local moderationDetail = p8496.moderationDetail;
        local verificationCategory = moderationDetail.verificationCategory;
        local v8502;

        if verificationCategory then
            v8502 = verificationCategory ~= "";
        else
            v8502 = verificationCategory;
        end;

        local v8503 = u8492(PUNISHMENT_TYPE_TO_INTERVENTION_MAP[moderationDetail.punishmentTypeDescription], moderationDetail.endDate, verificationCategory) and not (v8502 or u8494(commutationEligibility)) and (not p8496.hasNavigatedForward and not v8498);
        local u8504 = useCallback(function() -- Line: 58317
            -- upvalues: u8499 (copy)
            u8499(true);
        end, {});
        local v8506 = useMemo(function() -- Line: 58321
            -- upvalues: FocusNavigationEventNameEnum (ref), u8495 (ref), u8504 (copy)
            return {
                [FocusNavigationEventNameEnum.NavigateBack] = {
                    handler = u8495.onRelease(function(p8505) -- Line: 58324
                        -- upvalues: u8504 (ref)
                        p8505.cancelled = true;
                        u8504();
                    end)
                }
            };
        end, { u8504 });
        local u8507 = useAppFocusRoot({
            isAutoFocusRoot = true,
            surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.PopUp,
            isFocusable = v8503,
            customEventHandlers = v8506
        });
        local v8509 = useCallback(function(p8508) -- Line: 58344
            -- upvalues: u8497 (copy), u8507 (copy)
            u8497.current = p8508;

            if type(u8507) == "function" then
                u8507(p8508);
            end;
        end, { u8507 });
        useEffect(function() -- Line: 58352
            -- upvalues: u8497 (copy)
            if u8497.current then
                u8497.current.SelectionBehaviorDown = Enum.SelectionBehavior.Stop;
                u8497.current.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop;
                u8497.current.SelectionBehaviorRight = Enum.SelectionBehavior.Stop;
                u8497.current.SelectionBehaviorUp = Enum.SelectionBehavior.Stop;
                u8497.current.SelectionGroup = true;
            end;
        end, { v8503 });

        return u8489.createElement(OverlayProvider, {
            gui = v8501
        }, {
            Coachmark = u8489.createElement(Coachmark, {
                title = translations.reactivationNoticeHeading,
                text = translations.reactivationNoticeDescription,
                isOpen = v8503,
                side = PopoverSide.Top,
                align = PopoverAlign.Center,
                anchorRef = p8496.anchorRef,
                onClose = u8504,
                ref = v8509
            })
        });
    end);
end;

function u2.fQj() -- Line: 58383
    return __DefineFastFlag("EnableNapReactivationNotice", false);
end;

function u2.fQc() -- Line: 58387
    -- upvalues: u2 (ref)
    local u8510 = u2.loadModule("fPf");
    local useCallback = u8510.useCallback;
    local useRef = u8510.useRef;
    local useState = u8510.useState;
    local v8511 = u2.loadModule("fPg");
    local Button = v8511.Button;
    local ButtonVariant = v8511.Enums.ButtonVariant;
    local InputSize = v8511.Enums.InputSize;
    local View = v8511.View;
    u2.loadModule("fPj");
    local u8512 = u2.loadModule("fQd");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8513 = u2.loadModule("fQj");

    return u8510.memo(function(p8514) -- Line: 58413, Name: ContinueButtonCta
        -- upvalues: useNotApprovedPageContext (copy), useState (copy), useRef (copy), useCallback (copy), u8513 (copy), u8510 (copy), View (copy), Button (copy), ButtonVariant (copy), InputSize (copy), u8512 (copy)
        local translations = useNotApprovedPageContext().translations;
        local v8515, u8516 = useState(nil);
        local u8517 = useRef(nil);
        local v8519 = useCallback(function(p8518) -- Line: 58421
            -- upvalues: u8517 (copy), u8516 (copy)
            u8517.current = p8518;
            u8516(p8518);
        end, {});

        if not u8513 then
            return u8510.createElement(Button, {
                testId = "continue-button",
                text = translations.continueButton,
                onActivated = p8514.goToNextPage,
                variant = ButtonVariant.Emphasis,
                size = InputSize.Medium,
                isDisabled = p8514.isDisabled or false,
                width = UDim.new(1, 0),
                LayoutOrder = p8514.layoutOrder or 1
            });
        end;

        local createElement = u8510.createElement;
        local v8520 = {
            tag = "size-full-0 auto-y",
            LayoutOrder = p8514.layoutOrder or 1,
            ref = v8519
        };
        local v8521 = {
            Button = u8510.createElement(Button, {
                testId = "continue-button",
                text = translations.continueButton,
                onActivated = p8514.goToNextPage,
                variant = ButtonVariant.Emphasis,
                size = InputSize.Medium,
                isDisabled = p8514.isDisabled or false,
                width = UDim.new(1, 0)
            })
        };

        if v8515 then
            v8515 = u8510.createElement(u8512, {
                moderationDetail = p8514.moderationDetail,
                anchorRef = u8517,
                hasNavigatedForward = p8514.hasNavigatedForward
            });
        end;

        v8521.Coachmark = v8515;

        return createElement(View, v8520, v8521);
    end);
end;

function u2.fQk() -- Line: 58464
    -- upvalues: u2 (ref)
    local u8522 = u2.loadModule("fPf");
    local Fragment = u8522.Fragment;
    local useCallback = u8522.useCallback;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local v8523 = u2.loadModule("fPg");
    local Button = v8523.Button;
    local ButtonVariant = v8523.Enums.ButtonVariant;
    local InputSize = v8523.Enums.InputSize;
    local u8524 = u2.loadModule("fPY");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8525 = u2.loadModule("fPk");
    local u8526 = u2.loadModule("fPL");
    local EVENT_TYPES = u2.loadModule("fPa").Constants.EVENT_TYPES;
    local FFlagNavigateToSafetyDashboardForAppeals = u2.loadModule("fPq").FFlagNavigateToSafetyDashboardForAppeals;
    u2.loadModule("fPj");

    return u8522.memo(function(p8527) -- Line: 58493, Name: DeleteCta
        -- upvalues: useNotApprovedPageContext (copy), u8526 (copy), FFlagNavigateToSafetyDashboardForAppeals (copy), u8524 (copy), UrlBuilder (copy), useCallback (copy), u8525 (copy), EVENT_TYPES (copy), u8522 (copy), Fragment (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
        local translations = useNotApprovedPageContext().translations;
        local violation = p8527.moderationDetail.violation;
        local v8528;

        if FFlagNavigateToSafetyDashboardForAppeals then
            v8528 = u8524(violation);
        else
            v8528 = UrlBuilder.static.appealsPortal.main();
        end;

        local v8529;

        if FFlagNavigateToSafetyDashboardForAppeals then
            v8529 = translations.accountStatusTitle;
        else
            v8529 = translations.appealsPortalTitle;
        end;

        local u8530 = u8526(v8528, v8529);
        local v8531 = useCallback(function() -- Line: 58506
            -- upvalues: u8525 (ref), EVENT_TYPES (ref), u8530 (copy)
            u8525({
                eventType = EVENT_TYPES.AppealsPortalClicked
            });
            u8530();
        end, { u8530 });

        return u8522.createElement(Fragment, nil, {
            AppealButton = u8522.createElement(Button, {
                LayoutOrder = 1,
                text = translations.reportMistakeButton,
                onActivated = v8531,
                variant = ButtonVariant.SoftEmphasis,
                size = InputSize.Medium,
                width = UDim.new(1, 0)
            })
        });
    end);
end;

function u2.fQm() -- Line: 58539
    -- upvalues: u2 (ref)
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8532 = u2.loadModule("fPf");
    local v8533 = u2.loadModule("fPg");
    local View = v8533.View;
    local Icon = v8533.Icon;
    local IconSize = v8533.Enums.IconSize;
    local Text = v8533.Text;
    local useTokens = v8533.Hooks.useTokens;
    local v8534 = u2.loadModule("fQn");
    local TriangleExclamation = v8534.Icon.TriangleExclamation;
    local IconVariant = v8534.IconVariant;

    return u8532.memo(function(p8535) -- Line: 58561, Name: SuspensionDurationAlert
        -- upvalues: useTokens (copy), useNotApprovedPageContext (copy), u8532 (copy), View (copy), Icon (copy), TriangleExclamation (copy), IconSize (copy), IconVariant (copy), Text (copy)
        local v8536 = useTokens();
        local translations = useNotApprovedPageContext().translations;

        return u8532.createElement(View, {
            tag = "size-full-0 auto-y row gap-medium padding-medium align-y-center stroke-thick stroke-default radius-medium bg-shift-100",
            testId = "suspension-duration-alert",
            LayoutOrder = p8535.layoutOrder
        }, {
            Icon = u8532.createElement(Icon, {
                LayoutOrder = 1,
                name = TriangleExclamation,
                size = IconSize.Medium,
                variant = IconVariant.Filled,
                style = v8536.Color.System.Warning
            }),
            Text = u8532.createElement(View, {
                tag = "auto-xy row gap-xsmall",
                LayoutOrder = 2
            }, {
                Label = u8532.createElement(Text, {
                    tag = "auto-xy text-title-medium content-emphasis text-align-x-left text-wrap",
                    LayoutOrder = 1,
                    Text = translations.suspensionLabel
                }),
                Value = u8532.createElement(Text, {
                    tag = "auto-xy text-body-medium text-align-x-left text-wrap",
                    LayoutOrder = 2,
                    Text = p8535.timeRemaining
                })
            })
        });
    end);
end;

function u2.fQp() -- Line: 58643
    -- upvalues: u2 (ref)
    local u8541 = u2.loadModule("fQq");
    local u8542 = u2.loadModule("fQr");
    local NotificationType = u2.loadModule("fPH").NotificationType;
    local SetModerationStatus = u2.loadModule("fPa").SetModerationStatus;
    local FFlagUseSignalsForModeration = u2.loadModule("fPq").FFlagUseSignalsForModeration;
    local u8543;

    if FFlagUseSignalsForModeration then
        u8543 = u2.loadModule("fPa").GetModerationStore;
    else
        u8543 = nil;
    end;

    local GuiService = game:GetService("GuiService");

    return function(u8544, u8545) -- Line: 58660, Name: ReactivateAccount
        -- upvalues: u8541 (copy), FFlagUseSignalsForModeration (copy), u8543 (copy), SetModerationStatus (copy), GuiService (copy), NotificationType (copy), u8542 (copy)
        return function(u8546) -- Line: 58661
            -- upvalues: u8541 (ref), u8544 (copy), u8545 (copy), FFlagUseSignalsForModeration (ref), u8543 (ref), SetModerationStatus (ref), GuiService (ref), NotificationType (ref), u8542 (ref)
            return u8541(u8544, u8545):andThen(function(p8547) -- Line: 58662
                -- upvalues: FFlagUseSignalsForModeration (ref), u8543 (ref), u8546 (copy), SetModerationStatus (ref), GuiService (ref), NotificationType (ref), u8542 (ref)
                if FFlagUseSignalsForModeration then
                    u8543(false).setModerationStatus(false);
                else
                    u8546:dispatch(SetModerationStatus(false));
                end;

                GuiService:BroadcastNotification("", NotificationType.RESTART_LUA_APP);

                return u8542.resolve();
            end, function(p8548) -- Line: 58670
                -- upvalues: u8542 (ref)
                return u8542.reject({
                    error = p8548
                });
            end);
        end;
    end;
end;

function u2.fQo() -- Line: 58680
    -- upvalues: u2 (ref)
    local u8549 = u2.loadModule("fQp");
    local u8550 = u2.loadModule("fPk");
    local Constants = u2.loadModule("fPa").Constants;
    local EVENT_TYPES = Constants.EVENT_TYPES;
    local VERIFICATION_TYPES = Constants.VERIFICATION_TYPES;
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;
    u2.loadModule("fPc");
    local u8551 = u2.loadModule("fPf");
    local useState = u8551.useState;
    local useMemo = u8551.useMemo;
    local useCallback = u8551.useCallback;
    local useDispatch = u2.loadModule("fPP").Hooks.RoactRodux.useDispatch;
    local useRoactService = u2.loadModule("fPN").useRoactService;
    local RoactNetworking = u2.loadModule("fPM").RoactNetworking;
    local NavigateDown = u2.loadModule("fPI").Thunks.NavigateDown;
    local NavigateBack = u2.loadModule("fPI").Thunks.NavigateBack;
    local AppPage = u2.loadModule("fPH").AppPage;
    local FFlagSignalsNavP3Dispatch = u2.loadModule("fPq").FFlagSignalsNavP3Dispatch;
    local FFlagLuaAppVpcUpsellNamespace = u2.loadModule("fPq").FFlagLuaAppVpcUpsellNamespace;
    local FStringLuaAppVpcAccountManagementAmpNameSpace = u2.loadModule("fPq").FStringLuaAppVpcAccountManagementAmpNameSpace;
    local u8552;

    if FFlagSignalsNavP3Dispatch then
        u8552 = u2.loadModule("fPK").NavigationCommands;
    else
        u8552 = nil;
    end;

    local v8553 = u2.loadModule("fPg");
    local Button = v8553.Button;
    local ButtonVariant = v8553.Enums.ButtonVariant;
    local InputSize = v8553.Enums.InputSize;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return u8551.memo(function(u8554) -- Line: 58729, Name: ReactivationButton
        -- upvalues: useState (copy), useDispatch (copy), useRoactService (copy), RoactNetworking (copy), useNotApprovedPageContext (copy), PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), useCallback (copy), EVENT_TYPES (copy), u8550 (copy), AppPage (copy), UrlBuilder (copy), FFlagSignalsNavP3Dispatch (copy), u8552 (copy), NavigateDown (copy), FFlagLuaAppVpcUpsellNamespace (copy), FStringLuaAppVpcAccountManagementAmpNameSpace (copy), NavigateBack (copy), u8549 (copy), useMemo (copy), VERIFICATION_TYPES (copy), INTERVENTION_TYPES (copy), u8551 (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
        local v8555, u8556 = useState(false);
        local u8557 = useDispatch();
        local u8558 = useRoactService(RoactNetworking);
        local translations = useNotApprovedPageContext().translations;
        local canReactivate = u8554.canReactivate;
        local moderationDetail = u8554.moderationDetail;
        local verificationCategory = moderationDetail.verificationCategory;
        local u8559 = PUNISHMENT_TYPE_TO_INTERVENTION_MAP[moderationDetail.punishmentTypeDescription];
        local u8561 = useCallback(function() -- Line: 58742
            -- upvalues: u8556 (copy), u8554 (copy), EVENT_TYPES (ref), u8550 (ref), AppPage (ref), UrlBuilder (ref), FFlagSignalsNavP3Dispatch (ref), u8552 (ref), u8557 (copy), NavigateDown (ref)
            u8556(true);

            if u8554.sendPageEvent then
                u8554.sendPageEvent(EVENT_TYPES.EmailVerificationClicked);
            else
                u8550({
                    eventType = EVENT_TYPES.EmailVerificationClicked
                });
            end;

            local v8560 = {
                name = AppPage.EmailVerification,
                detail = UrlBuilder.fromString("www:")()
            };

            if FFlagSignalsNavP3Dispatch then
                u8552.down(u8552.fromLegacyPage(v8560));

                return;
            end;

            u8557(NavigateDown(v8560));
        end, { u8557 });
        local u8567 = useCallback(function() -- Line: 58763
            -- upvalues: u8556 (copy), u8554 (copy), EVENT_TYPES (ref), u8550 (ref), AppPage (ref), FFlagLuaAppVpcUpsellNamespace (ref), FStringLuaAppVpcAccountManagementAmpNameSpace (ref), FFlagSignalsNavP3Dispatch (ref), u8552 (ref), u8557 (copy), NavigateBack (ref), NavigateDown (ref)
            u8556(true);

            if u8554.sendPageEvent then
                u8554.sendPageEvent(EVENT_TYPES.ParentVerificationClicked);
            else
                u8550({
                    eventType = EVENT_TYPES.ParentVerificationClicked
                });
            end;

            local v8562 = {
                name = AppPage.AmpWizardContainer
            };
            local v8563 = {
                featureName = "CanRequestPunishmentLifting",
                entryPointEventCtx = "banScreenChargebackLiftPunishment",
                recourseData = {
                    punishmentType = "Chargeback"
                }
            };
            local v8564;

            if FFlagLuaAppVpcUpsellNamespace then
                v8564 = FStringLuaAppVpcAccountManagementAmpNameSpace;
            else
                v8564 = nil;
            end;

            v8563.nameSpace = v8564;

            function v8563.completionCallback(p8565, p8566) -- Line: 58780
                -- upvalues: FFlagSignalsNavP3Dispatch (ref), u8552 (ref), u8557 (ref), NavigateBack (ref), u8556 (ref)
                if FFlagSignalsNavP3Dispatch then
                    u8552.back();
                else
                    u8557(NavigateBack());
                end;

                u8556(false);
            end;

            v8562.extraProps = v8563;

            if FFlagSignalsNavP3Dispatch then
                u8552.down(u8552.fromLegacyPage(v8562));

                return;
            end;

            u8557(NavigateDown(v8562));
        end, {
            u8557,
            moderationDetail,
            u8559,
            u8554.LogoutThunk
        });
        local u8568 = useCallback(function() -- Line: 58797
            -- upvalues: u8556 (copy), u8554 (copy), EVENT_TYPES (ref), u8550 (ref), u8557 (copy), u8549 (ref), u8558 (copy), moderationDetail (copy)
            u8556(true);

            if u8554.sendPageEvent then
                u8554.sendPageEvent(EVENT_TYPES.ReactivateClicked);
            else
                u8550({
                    eventType = EVENT_TYPES.ReactivateClicked
                });
            end;

            u8557(u8549(u8558, moderationDetail.punishmentId)):andThen(function() -- Line: 58806
                -- upvalues: u8556 (ref)
                u8556(false);
            end);
        end, { u8557, u8558, moderationDetail.punishmentId });
        local v8569 = useMemo(function() -- Line: 58811
            -- upvalues: verificationCategory (copy), VERIFICATION_TYPES (ref), translations (copy), u8567 (copy), u8561 (copy), u8559 (copy), INTERVENTION_TYPES (ref), canReactivate (copy), u8568 (copy)
            return verificationCategory == VERIFICATION_TYPES.Parent and {
                label = translations.parentVerificationButton,
                action = u8567
            } or (verificationCategory == VERIFICATION_TYPES.Email and {
                label = translations.emailVerificationButton,
                action = u8561
            } or (u8559 == INTERVENTION_TYPES.Banned and not canReactivate and {
                label = translations.continueButton,

                action = function() -- Line: 58825, Name: action
                end
            } or {
                label = translations.continueButton,
                action = u8568
            }));
        end, {
            canReactivate,
            u8567,
            u8561,
            u8568,
            moderationDetail.endDate,
            verificationCategory,
            u8559
        });

        return u8551.createElement(Button, {
            testId = "reactivation-button",
            text = v8569.label,
            onActivated = v8569.action,
            variant = ButtonVariant.Emphasis,
            size = InputSize.Medium,
            width = UDim.new(1, 0),
            isLoading = v8555,
            isDisabled = not canReactivate or (not u8554.isAgreed or v8555),
            LayoutOrder = u8554.layoutOrder
        });
    end);
end;

function u2.fQs() -- Line: 58859
    -- upvalues: u2 (ref)
    local u8570 = u2.loadModule("fPb");
    local Localization = u2.loadModule("fPp").Localization;
    local LocalizationService = game:GetService("LocalizationService");
    local u8571 = Localization.new(LocalizationService.RobloxLocaleId);

    return function(p8572) -- Line: 58872, Name: calculateDaysRemaining
        -- upvalues: u8571 (copy), u8570 (copy)
        local DateTime_fromIsoDate_ret = DateTime.fromIsoDate(p8572);

        if not DateTime_fromIsoDate_ret then
            return u8571:Format("Feature.NotApproved.Label.Hours", {
                hours = string.format("%02d", 0),
                minutes = string.format("%02d", 0)
            });
        end;

        local v8573 = u8570.Workspace:GetServerTimeNow() * 1000;
        local v8574 = DateTime_fromIsoDate_ret.UnixTimestampMillis - v8573;
        local v8575 = v8574 < 0 and 0 or v8574;

        if v8575 > 86400000 then
            return u8571:Format("Feature.NotApproved.Label.Days", {
                number = math.ceil(v8575 / 86400000)
            });
        end;

        local math_floor_ret = math.floor(v8575 / 3600000);
        local math_floor_ret2 = math.floor(v8575 % 3600000 / 60000);

        return u8571:Format("Feature.NotApproved.Label.Hours", {
            hours = string.format("%02d", math_floor_ret),
            minutes = string.format("%02d", v8575 > 0 and v8575 < 60000 and 1 or math_floor_ret2)
        });
    end;
end;

function u2.fQl() -- Line: 58911
    -- upvalues: u2 (ref)
    local u8576 = u2.loadModule("fPf");
    local Fragment = u8576.Fragment;
    local useState = u8576.useState;
    local useEffect = u8576.useEffect;
    local v8577 = u2.loadModule("fPg");
    local Checkbox = v8577.Checkbox;
    local InputSize = v8577.Enums.InputSize;
    u2.loadModule("fPj");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8578 = u2.loadModule("fQm");
    local u8579 = u2.loadModule("fQo");
    local u8580 = u2.loadModule("fOZ");
    local u8581 = u2.loadModule("fQs");
    local u8582 = u2.loadModule("fPk");
    local Constants = u2.loadModule("fPa").Constants;
    local EVENT_TYPES = Constants.EVENT_TYPES;
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;

    return u8576.memo(function(p8583) -- Line: 58944, Name: ProceedActionsCta
        -- upvalues: useNotApprovedPageContext (copy), PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), u8580 (copy), useState (copy), useEffect (copy), INTERVENTION_TYPES (copy), u8576 (copy), u8582 (copy), EVENT_TYPES (copy), u8581 (copy), Fragment (copy), u8578 (copy), Checkbox (copy), InputSize (copy), u8579 (copy)
        local translations = useNotApprovedPageContext().translations;
        local moderationDetail = p8583.moderationDetail;
        local endDate = moderationDetail.endDate;
        local punishmentTypeDescription = moderationDetail.punishmentTypeDescription;
        local u8584 = PUNISHMENT_TYPE_TO_INTERVENTION_MAP[punishmentTypeDescription];
        local v8585 = u8580(u8584, endDate, moderationDetail.verificationCategory);
        local v8586, u8587 = useState(false);
        local v8588, u8589 = useState(false);
        useEffect(function() -- Line: 58959
            -- upvalues: u8584 (copy), INTERVENTION_TYPES (ref), u8589 (copy)
            if u8584 == INTERVENTION_TYPES.Banned then
                local task_delay_ret = task.delay(60, function() -- Line: 58965
                    -- upvalues: u8589 (ref)
                    u8589(function(p8590) -- Line: 58966
                        return not p8590;
                    end);
                end);

                return function() -- Line: 58971
                    -- upvalues: task_delay_ret (copy)
                    if task_delay_ret and typeof(task_delay_ret) == "thread" then
                        task.cancel(task_delay_ret);
                    end;
                end;
            end;
        end, { v8588, punishmentTypeDescription });
        local v8592 = u8576.useCallback(function(p8591) -- Line: 58978
            -- upvalues: u8587 (copy), u8582 (ref), EVENT_TYPES (ref)
            u8587(p8591);
            u8582({
                eventType = EVENT_TYPES.CheckboxChecked
            });
        end, {});
        local v8593 = not v8585;
        local v8594 = u8581(endDate);
        local createElement = u8576.createElement;
        local v8595 = {};
        local v8596;

        if v8593 then
            v8596 = u8576.createElement(u8578, {
                layoutOrder = 1,
                timeRemaining = v8594
            });
        else
            v8596 = v8593;
        end;

        v8595.SuspensionDurationAlert = v8596;
        local v8597 = not v8593 and u8576.createElement(Checkbox, {
            LayoutOrder = 2,
            isChecked = v8586,
            size = InputSize.Small,
            onActivated = v8592,
            label = translations.acknowledgementCheckboxLabel
        });
        v8595.AgreeCheckbox = v8597;
        v8595.ReactivationButton = u8576.createElement(u8579, {
            layoutOrder = 3,
            moderationDetail = moderationDetail,
            LogoutThunk = p8583.LogoutThunk,
            isAgreed = v8586,
            canReactivate = v8585,
            sendPageEvent = p8583.sendPageEvent
        });

        return createElement(Fragment, nil, v8595);
    end);
end;

function u2.fQu() -- Line: 59014
    -- upvalues: u2 (ref)
    local u8598 = u2.loadModule("fPf");
    local v8599 = u2.loadModule("fPg");
    local ButtonSize = v8599.Enums.ButtonSize;
    local ButtonVariant = v8599.Enums.ButtonVariant;
    local Icon = v8599.Icon;
    local IconButton = v8599.IconButton;
    local InputSize = v8599.Enums.InputSize;
    local Text = v8599.Text;
    local View = v8599.View;
    local useTokens = v8599.Hooks.useTokens;
    local v8600 = u2.loadModule("fQn");
    local CircleX = v8600.Icon.CircleX;
    local IconVariant = v8600.IconVariant;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return u8598.memo(function(p8601) -- Line: 59039, Name: ErrorAlert
        -- upvalues: useTokens (copy), useNotApprovedPageContext (copy), u8598 (copy), View (copy), Icon (copy), CircleX (copy), InputSize (copy), IconVariant (copy), Text (copy), IconButton (copy), ButtonVariant (copy), ButtonSize (copy)
        local v8602 = useTokens();
        local translations = useNotApprovedPageContext().translations;

        return u8598.createElement(View, {
            tag = "size-full-0 auto-y row flex-between gap-medium padding-medium radius-medium align-y-center stroke-standard stroke-system-alert",
            testId = "error-alert",
            backgroundStyle = {
                Transparency = 0.9,
                Color3 = v8602.Color.System.Alert.Color3
            },
            LayoutOrder = p8601.layoutOrder or 1
        }, {
            Container = u8598.createElement(View, {
                tag = "auto-xy row gap-small align-y-center",
                LayoutOrder = 1
            }, {
                Icon = u8598.createElement(Icon, {
                    LayoutOrder = 1,
                    name = CircleX,
                    size = InputSize.Medium,
                    variant = IconVariant.Filled,
                    style = v8602.Color.System.Alert
                }),
                Text = u8598.createElement(Text, {
                    tag = "auto-xy text-body-medium text-align-x-left text-wrap content-emphasis",
                    LayoutOrder = 2,
                    Text = translations.errorMessage
                })
            }),
            Button = u8598.createElement(IconButton, {
                icon = "x-small",
                isCircular = true,
                LayoutOrder = 2,
                variant = ButtonVariant.Utility,
                onActivated = p8601.onClose,
                size = ButtonSize.Small
            })
        });
    end);
end;

function u2.fQt() -- Line: 59124
    -- upvalues: u2 (ref)
    local GuiService = game:GetService("GuiService");
    local NotificationType = u2.loadModule("fPH").NotificationType;
    local RoactNetworking = u2.loadModule("fPM").RoactNetworking;
    local UrlBuilder = u2.loadModule("fPJ").UrlBuilder;
    local useRoactService = u2.loadModule("fPN").useRoactService;
    local u8604 = u2.loadModule("fPf");
    local Fragment = u8604.Fragment;
    local useState = u8604.useState;
    local useCallback = u8604.useCallback;
    local v8605 = u2.loadModule("fPg");
    local Button = v8605.Button;
    local ButtonVariant = v8605.Enums.ButtonVariant;
    local InputSize = v8605.Enums.InputSize;
    local EVENT_TYPES = u2.loadModule("fPa").Constants.EVENT_TYPES;
    u2.loadModule("fPj");
    local u8606 = u2.loadModule("fQu");
    local u8607 = u2.loadModule("fQv");
    local SetModerationStatus = u2.loadModule("fPa").SetModerationStatus;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local FFlagUseSignalsForModeration = u2.loadModule("fPq").FFlagUseSignalsForModeration;
    local u8608;

    if FFlagUseSignalsForModeration then
        u8608 = u2.loadModule("fPa").GetModerationStore;
    else
        u8608 = nil;
    end;

    local u8609 = u2.loadModule("fPY");
    local u8610 = u2.loadModule("fPL");
    local FFlagNavigateToSafetyDashboardForAppeals = u2.loadModule("fPq").FFlagNavigateToSafetyDashboardForAppeals;

    return u8604.memo(function(p8611) -- Line: 59166, Name: SecondChanceActionsCta
        -- upvalues: useNotApprovedPageContext (copy), u8610 (copy), FFlagNavigateToSafetyDashboardForAppeals (copy), u8609 (copy), UrlBuilder (copy), useRoactService (copy), RoactNetworking (copy), useState (copy), useCallback (copy), EVENT_TYPES (copy), u8607 (copy), FFlagUseSignalsForModeration (copy), u8608 (copy), SetModerationStatus (copy), GuiService (copy), NotificationType (copy), u8604 (copy), Fragment (copy), u8606 (copy), Button (copy), ButtonVariant (copy), InputSize (copy)
        local translations = useNotApprovedPageContext().translations;
        local violation = p8611.moderationDetail.violation;
        local v8612;

        if FFlagNavigateToSafetyDashboardForAppeals then
            v8612 = u8609(violation);
        else
            v8612 = UrlBuilder.static.appealsPortal.main();
        end;

        local v8613;

        if FFlagNavigateToSafetyDashboardForAppeals then
            v8613 = translations.accountStatusTitle;
        else
            v8613 = translations.appealsPortalTitle;
        end;

        local u8614 = u8610(v8612, v8613);
        local u8615 = useRoactService(RoactNetworking);
        local dispatch = p8611.dispatch;
        local sendPageEvent = p8611.sendPageEvent;
        local v8616, u8617 = useState(false);
        local v8618, u8619 = useState(false);
        local v8622 = useCallback(function() -- Line: 59186
            -- upvalues: u8617 (copy), sendPageEvent (copy), EVENT_TYPES (ref), u8607 (ref), u8615 (copy), u8619 (copy), FFlagUseSignalsForModeration (ref), u8608 (ref), dispatch (copy), SetModerationStatus (ref), GuiService (ref), NotificationType (ref)
            u8617(true);

            if sendPageEvent then
                sendPageEvent(EVENT_TYPES.SecondChanceReactivateClicked);
            end;

            u8607(u8615):andThen(function(p8620) -- Line: 59194
                -- upvalues: u8619 (ref), FFlagUseSignalsForModeration (ref), u8608 (ref), dispatch (ref), SetModerationStatus (ref), GuiService (ref), NotificationType (ref)
                u8619(false);

                if FFlagUseSignalsForModeration then
                    u8608(false).setModerationStatus(false);
                else
                    dispatch(SetModerationStatus(false));
                end;

                GuiService:BroadcastNotification("", NotificationType.RESTART_LUA_APP);
            end):catch(function(p8621) -- Line: 59203
                -- upvalues: u8619 (ref), u8617 (ref)
                u8619(true);
                u8617(false);
            end);
        end, { sendPageEvent, u8615, dispatch });
        local v8623 = useCallback(function() -- Line: 59209
            -- upvalues: sendPageEvent (copy), EVENT_TYPES (ref), u8614 (copy)
            if sendPageEvent then
                sendPageEvent(EVENT_TYPES.AppealsPortalClicked);
            end;

            u8614();
        end, { u8614, sendPageEvent });
        local v8624 = useCallback(function() -- Line: 59216
            -- upvalues: u8619 (copy)
            u8619(false);
        end, {});
        local createElement = u8604.createElement;
        local v8625 = {};

        if v8618 then
            v8618 = u8604.createElement(u8606, {
                layoutOrder = 1,
                onClose = v8624
            });
        end;

        v8625.ErrorAlert = v8618;
        v8625.ReactivateButton = u8604.createElement(Button, {
            LayoutOrder = 2,
            testId = "second-chance-reactivate-button",
            text = translations.okButton,
            onActivated = v8622,
            variant = ButtonVariant.Emphasis,
            size = InputSize.Medium,
            width = UDim.new(1, 0),
            isLoading = v8616,
            isDisabled = v8616
        });
        v8625.SendAppealButton = u8604.createElement(Button, {
            LayoutOrder = 3,
            testId = "second-chance-send-appeal-button",
            text = translations.sendAppealButton,
            onActivated = v8623,
            variant = ButtonVariant.Standard,
            size = InputSize.Medium,
            width = UDim.new(1, 0)
        });

        return createElement(Fragment, nil, v8625);
    end);
end;

function u2.fQx() -- Line: 59253
    -- upvalues: u2 (ref)
    local u8626 = u2.loadModule("fPf");
    local Fragment = u8626.Fragment;
    local useState = u8626.useState;
    local useCallback = u8626.useCallback;
    local v8627 = u2.loadModule("fPg");
    local Checkbox = v8627.Checkbox;
    local InputSize = v8627.Enums.InputSize;
    local u8628 = u2.loadModule("fQc");
    u2.loadModule("fPj");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return u8626.memo(function(p8629) -- Line: 59276, Name: UnderstandRuleContinueCta
        -- upvalues: useNotApprovedPageContext (copy), useState (copy), useCallback (copy), u8626 (copy), Fragment (copy), Checkbox (copy), InputSize (copy), u8628 (copy)
        local translations = useNotApprovedPageContext().translations;
        local v8630, u8631 = useState(false);
        local v8633 = useCallback(function(p8632) -- Line: 59280
            -- upvalues: u8631 (copy)
            u8631(p8632);
        end, {});

        return u8626.createElement(Fragment, nil, {
            AcknowledgementCheckbox = u8626.createElement(Checkbox, {
                LayoutOrder = 1,
                isChecked = v8630,
                size = InputSize.Small,
                onActivated = v8633,
                label = translations.acknowledgementCheckboxLabel
            }),
            ContinueButton = u8626.createElement(u8628, {
                layoutOrder = 2,
                moderationDetail = p8629.moderationDetail,
                dispatch = p8629.dispatch,
                isDisabled = not v8630,
                LogoutThunk = p8629.LogoutThunk,
                goToNextPage = p8629.goToNextPage,
                hasNavigatedForward = p8629.hasNavigatedForward
            })
        });
    end);
end;

function u2.fPm() -- Line: 59308
    -- upvalues: u2 (ref)
    local Constants = u2.loadModule("fPa").Constants;
    local u8634 = u2.loadModule("fPn");
    local u8635 = u2.loadModule("fPd");
    local v8636 = u2.loadModule("fPq");
    u2.loadModule("fPc");
    local v8637 = u2.loadModule("fPj");
    local u8638 = u2.loadModule("fPr");
    local u8639 = u2.loadModule("fPu");
    local u8640 = u2.loadModule("fPF");
    local u8641 = u2.loadModule("fPG");
    local u8642 = u2.loadModule("fPS");
    local u8643 = u2.loadModule("fPU");
    local u8644 = u2.loadModule("fPX");
    local u8645 = u2.loadModule("fPZ");
    local u8646 = u2.loadModule("fQa");
    local u8647 = u2.loadModule("fPW");
    local u8648 = u2.loadModule("fPV");
    local u8649 = u2.loadModule("fQb");
    local u8650 = u2.loadModule("fQc");
    local u8651 = u2.loadModule("fQk");
    local u8652 = u2.loadModule("fQl");
    local u8653 = u2.loadModule("fQt");
    local u8654 = u2.loadModule("fQx");
    local EDUCATIONAL_PAGE_PREFIXES = v8637.EDUCATIONAL_PAGE_PREFIXES;
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local u8655 = u2.loadModule("fPt");
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;
    local STATIC_PAGE_NAMES = v8637.STATIC_PAGE_NAMES;
    local FFlagKidsNotApprovedPageTreatment = v8636.FFlagKidsNotApprovedPageTreatment;

    local function getEducationalPages(p8656, p8657, p8658, p8659) -- Line: 59364
        -- upvalues: FFlagKidsNotApprovedPageTreatment (copy), u8638 (copy), EDUCATIONAL_PAGE_PREFIXES (copy), u8634 (copy), u8654 (copy), u8650 (copy), u8635 (copy), u8655 (copy)
        if not FFlagKidsNotApprovedPageTreatment then
            local v8660 = {};
            local v8661 = {};
            local v8662 = {};

            for _, v in ipairs(p8657) do
                local v8663 = u8655[v];

                if v8663 then
                    if not v8660[v8663.policyKey] then
                        v8660[v8663.policyKey] = true;
                        local v8664 = {
                            pageName = `{EDUCATIONAL_PAGE_PREFIXES.Rule}{v8663.policyKey}`,
                            pageItems = { u8634({
                                    title = v8663.ruleTitle,
                                    subtitle = v8663.ruleSubtitle,
                                    description = v8663.ruleDescription,
                                    descriptionBullets = v8663.ruleDescriptionBullets,
                                    policyKey = v8663.policyKey
                                }) }
                        };
                        local v8665;

                        if p8658 then
                            v8665 = u8654;
                        else
                            v8665 = u8650;
                        end;

                        v8664.CtaComponent = v8665;
                        table.insert(v8661, v8664);
                        local v8666 = {
                            pageName = `{EDUCATIONAL_PAGE_PREFIXES.Importance}{v8663.policyKey}`,
                            pageItems = { u8634({
                                    title = v8663.importanceTitle,
                                    description = v8663.importanceDescription,
                                    policyKey = v8663.policyKey
                                }) }
                        };
                        local v8667;

                        if p8658 then
                            v8667 = u8654;
                        else
                            v8667 = u8650;
                        end;

                        v8666.CtaComponent = v8667;
                        table.insert(v8661, v8666);
                    end;
                else
                    v8662[v] = true;
                end;
            end;

            return {
                educationalPages = v8661,
                unmappedViolationKeys = u8635.Dictionary.keys(v8662)
            };
        end;

        local v8668 = {};
        local v8669 = {};
        local v8670 = {};
        local v8671 = {};

        for _, v in ipairs(p8657) do
            local v8672 = u8638(v, p8659);

            if v8672 then
                local v8673 = v8672.deduplicationKey or v8672.policyKey;
                local v8674 = v8668[v8673];

                if v8674 then
                    if v8672.deduplicationKey and not v8674.deduplicationKey then
                        v8668[v8673] = v8672;
                    end;
                else
                    v8668[v8673] = v8672;
                    table.insert(v8669, v8673);
                end;
            else
                v8670[v] = true;
            end;
        end;

        for _, v in ipairs(v8669) do
            local v8675 = v8668[v];
            local v8676 = {
                pageName = `{EDUCATIONAL_PAGE_PREFIXES.Rule}{v8675.policyKey}`,
                pageItems = { u8634({
                        title = v8675.ruleTitle,
                        subtitle = v8675.ruleSubtitle,
                        description = v8675.ruleDescription,
                        descriptionBullets = v8675.ruleDescriptionBullets,
                        policyKey = v8675.policyKey
                    }) }
            };
            local v8677;

            if p8658 then
                v8677 = u8654;
            else
                v8677 = u8650;
            end;

            v8676.CtaComponent = v8677;
            table.insert(v8671, v8676);
            local v8678 = {
                pageName = `{EDUCATIONAL_PAGE_PREFIXES.Importance}{v8675.policyKey}`,
                pageItems = { u8634({
                        title = v8675.importanceTitle,
                        description = v8675.importanceDescription,
                        descriptionBullets = v8675.importanceDescriptionBullets,
                        policyKey = v8675.policyKey
                    }) }
            };
            local v8679;

            if p8658 then
                v8679 = u8654;
            else
                v8679 = u8650;
            end;

            v8678.CtaComponent = v8679;
            table.insert(v8671, v8678);
        end;

        return {
            educationalPages = v8671,
            unmappedViolationKeys = u8635.Dictionary.keys(v8670)
        };
    end;

    return {
        generatePages = function(p8680, p8681, p8682, p8683) -- Line: 59502, Name: generatePages
            -- upvalues: PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), INTERVENTION_TYPES (copy), STATIC_PAGE_NAMES (copy), u8642 (copy), u8649 (copy), u8643 (copy), u8651 (copy), u8650 (copy), u8646 (copy), u8644 (copy), getEducationalPages (copy), u8641 (copy), u8640 (copy), u8654 (copy), u8652 (copy), u8645 (copy), u8653 (copy)
            local v8684 = {};
            local v8685 = PUNISHMENT_TYPE_TO_INTERVENTION_MAP[p8680.punishmentTypeDescription] == INTERVENTION_TYPES.Deleted;
            local v8686;

            if p8682 then
                v8686 = p8682.educational_pass_eligible;
            else
                v8686 = false;
            end;

            local v8687 = {
                pageName = STATIC_PAGE_NAMES.Intro,
                pageItems = { u8642, u8649, u8643 }
            };
            local v8688;

            if v8685 then
                v8688 = u8651;
            else
                v8688 = u8650;
            end;

            v8687.CtaComponent = v8688;
            table.insert(v8684, v8687);

            if v8685 then
                return {
                    pages = v8684,
                    unmappedViolationKeys = {}
                };
            end;

            if v8686 then
                table.insert(v8684, {
                    pageName = STATIC_PAGE_NAMES.SecondChanceIntro,
                    pageItems = { u8646, u8644 },
                    CtaComponent = u8650
                });
            end;

            local v8689 = getEducationalPages(p8680, p8681, v8686, p8683 or false);

            for _, v in v8689.educationalPages do
                table.insert(v8684, v);
            end;

            local v8690 = {
                pageName = STATIC_PAGE_NAMES.Resolution,
                pageItems = { u8641, u8640, u8644 }
            };
            local v8691;

            if v8686 then
                v8691 = u8654;
            else
                v8691 = u8652;
            end;

            v8690.CtaComponent = v8691;
            table.insert(v8684, v8690);

            if v8686 then
                table.insert(v8684, {
                    pageName = STATIC_PAGE_NAMES.SecondChanceConclusion,
                    pageItems = { u8645 },
                    CtaComponent = u8653
                });
            end;

            return {
                pages = v8684,
                unmappedViolationKeys = v8689.unmappedViolationKeys
            };
        end,

        getReviewedEvidencePageItemConfigs = function() -- Line: 59357, Name: getReviewedEvidencePageItemConfigs
            -- upvalues: u8648 (copy), u8639 (copy), u8647 (copy)
            return { u8648, u8639, u8647 };
        end
    };
end;

function u2.fPl() -- Line: 59586
    -- upvalues: u2 (ref)
    local u8692 = u2.loadModule("fPi");
    local generatePages = u2.loadModule("fPm").generatePages;
    local v8693 = u2.loadModule("fPj");
    local u8694 = u2.loadModule("fPr");
    u2.loadModule("fPc");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local u8695 = u2.loadModule("fPf");
    local useMemo = u8695.useMemo;
    local useState = u8695.useState;
    local useCallback = u8695.useCallback;
    local useContext = u8695.useContext;
    local createContext = u8695.createContext;
    local u8696 = u2.loadModule("fQj");
    local STATIC_PAGE_NAMES = v8693.STATIC_PAGE_NAMES;
    local u8697 = createContext({});

    return {
        PageNavigationProvider = function(u8698) -- Line: 59624, Name: PageNavigationProvider
            -- upvalues: useState (copy), useNotApprovedPageContext (copy), useMemo (copy), generatePages (copy), STATIC_PAGE_NAMES (copy), useCallback (copy), u8696 (copy), u8694 (copy), u8695 (copy), u8697 (copy)
            local u8699, u8700 = useState(1);
            local u8701, u8702 = useState(false);
            local v8703 = useNotApprovedPageContext();
            local untranslatedReasons = v8703.violationReasons.untranslatedReasons;
            local commutationEligibility = v8703.commutationEligibility;
            local isKidsTreatment = v8703.isKidsTreatment;
            local v8704 = useMemo(function() -- Line: 59633
                -- upvalues: generatePages (ref), u8698 (copy), untranslatedReasons (copy), commutationEligibility (copy), isKidsTreatment (copy)
                return generatePages(u8698.moderationDetail, untranslatedReasons, commutationEligibility, isKidsTreatment);
            end, {
                u8698.moderationDetail,
                untranslatedReasons,
                commutationEligibility,
                isKidsTreatment
            });
            local pages = v8704.pages;
            local unmappedViolationKeys = v8704.unmappedViolationKeys;
            local u8705 = #pages;
            local u8706 = pages[u8699];
            local u8707;

            if u8706 then
                u8707 = u8706.pageName;
            else
                u8707 = STATIC_PAGE_NAMES.Unknown;
            end;

            local u8708;

            if commutationEligibility then
                u8708 = commutationEligibility.educational_pass_eligible;
            else
                u8708 = false;
            end;

            local u8710 = useCallback(function() -- Line: 59648
                -- upvalues: u8699 (copy), u8705 (copy), u8696 (ref), u8702 (copy), u8700 (copy)
                if u8699 < u8705 then
                    if u8696 then
                        u8702(true);
                    end;

                    u8700(function(p8709) -- Line: 59653
                        return p8709 + 1;
                    end);
                end;
            end, { u8699, u8705 });
            local u8712 = useCallback(function() -- Line: 59659
                -- upvalues: u8699 (copy), u8700 (copy)
                if u8699 > 1 then
                    u8700(function(p8711) -- Line: 59661
                        return p8711 - 1;
                    end);
                end;
            end, { u8699 });
            local u8713 = u8699 == 1;
            local u8714 = u8699 == u8705;
            local u8717 = useCallback(function() -- Line: 59672
                -- upvalues: u8705 (copy), u8707 (copy), STATIC_PAGE_NAMES (ref), u8699 (copy), u8708 (copy)
                if u8705 <= 1 or (u8707 == STATIC_PAGE_NAMES.Intro or u8707 == STATIC_PAGE_NAMES.SecondChanceIntro) then
                    return 0;
                end;

                local v8715 = u8705 - 1;
                local v8716 = u8699 - 1;

                if u8708 then
                    v8715 = v8715 - 1;
                    v8716 = v8716 - 1;
                end;

                return v8715 <= 0 and 0 or math.round(v8716 / v8715 * 100);
            end, {
                u8699,
                u8705,
                u8707,
                u8708
            });
            local u8718 = useMemo(function() -- Line: 59700
                -- upvalues: untranslatedReasons (copy), u8694 (ref), isKidsTreatment (copy)
                for _, v in untranslatedReasons do
                    if u8694(v, isKidsTreatment) then
                        return true;
                    end;
                end;

                return false;
            end, { untranslatedReasons, isKidsTreatment });
            local v8722 = useMemo(function() -- Line: 59709
                -- upvalues: u8699 (copy), u8707 (copy), u8705 (copy), u8710 (copy), u8712 (copy), u8713 (copy), u8714 (copy), u8717 (copy), u8718 (copy), u8696 (ref), u8701 (copy), u8706 (copy), unmappedViolationKeys (copy)
                local v8719 = {
                    currentPage = u8699,
                    currentPageName = u8707,
                    totalPages = u8705,
                    goToNextPage = u8710,
                    goToPreviousPage = u8712,
                    isFirstPage = u8713,
                    isLastPage = u8714,
                    getProgress = u8717,
                    hasEducationalPages = u8718
                };
                local v8720;

                if u8696 then
                    v8720 = u8701;
                else
                    v8720 = false;
                end;

                v8719.hasNavigatedForward = v8720;
                v8719.currentPageConfigs = not u8706 and {} or u8706.pageItems;
                local v8721;

                if u8706 then
                    v8721 = u8706.CtaComponent;
                else
                    v8721 = nil;
                end;

                v8719.CurrentCtaComponent = v8721;
                v8719.unmappedViolationKeys = unmappedViolationKeys;

                return v8719;
            end, {
                u8699,
                u8705,
                u8707,
                u8710,
                u8712,
                u8713,
                u8714,
                u8717,
                pages,
                u8718,
                u8701,
                unmappedViolationKeys,
                u8706
            });

            return u8695.createElement(u8697.Provider, {
                value = v8722
            }, u8698.children);
        end,

        usePageNavigation = function() -- Line: 59745, Name: usePageNavigation
            -- upvalues: useContext (copy), u8697 (copy), u8692 (copy)
            local v8723 = useContext(u8697);
            local v8724;

            if v8723 then
                v8724 = v8723.currentPage ~= nil;
            else
                v8724 = v8723;
            end;

            u8692.assert(v8724, "usePageNavigation must be used within PageNavigationProvider");

            return v8723;
        end
    };
end;

function u2.fPh() -- Line: 59762
    -- upvalues: u2 (ref)
    local u8725 = u2.loadModule("fPi");
    local u8726 = u2.loadModule("fPd");
    local Constants = u2.loadModule("fPa").Constants;
    u2.loadModule("fPj");
    local u8727 = u2.loadModule("fPk");
    u2.loadModule("fPc");
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;
    local u8728 = u2.loadModule("fPf");
    local createContext = u8728.createContext;
    local useCallback = u8728.useCallback;
    local useContext = u8728.useContext;
    local useEffect = u8728.useEffect;
    local useMemo = u8728.useMemo;
    local useRef = u8728.useRef;
    local EVENT_TYPES = Constants.EVENT_TYPES;
    local FFlagKidsNotApprovedPageTreatment = u2.loadModule("fPq").FFlagKidsNotApprovedPageTreatment;
    local u8729 = createContext({});

    return {
        PageAnalyticsProvider = function(p8730) -- Line: 59796, Name: PageAnalyticsProvider
            -- upvalues: usePageNavigation (copy), useRef (copy), useEffect (copy), EVENT_TYPES (copy), FFlagKidsNotApprovedPageTreatment (copy), u8727 (copy), useCallback (copy), u8726 (copy), useMemo (copy), u8728 (copy), u8729 (copy)
            local v8731 = usePageNavigation();
            local currentPage = v8731.currentPage;
            local currentPageName = v8731.currentPageName;
            local unmappedViolationKeys = v8731.unmappedViolationKeys;
            local u8732 = useRef(DateTime.now().UnixTimestampMillis);
            local u8733 = useRef(currentPage);
            local u8734 = useRef(currentPageName);
            local u8735 = useRef(true);
            local u8736 = p8730.isKidsTreatment or false;

            local function getTimeOnPageMs() -- Line: 59809
                -- upvalues: u8732 (copy)
                return DateTime.now().UnixTimestampMillis - u8732.current;
            end;

            useEffect(function() -- Line: 59814
                -- upvalues: unmappedViolationKeys (copy), EVENT_TYPES (ref), FFlagKidsNotApprovedPageTreatment (ref), u8736 (copy), u8727 (ref)
                for _, v in unmappedViolationKeys do
                    local v8737 = {
                        eventType = EVENT_TYPES.UnmappedViolationKey,
                        unmappedViolationKey = v
                    };

                    if FFlagKidsNotApprovedPageTreatment then
                        v8737.isKidsTreatment = tostring(u8736);
                    end;

                    u8727(v8737);
                end;
            end, {});
            useEffect(function() -- Line: 59828
                -- upvalues: u8735 (copy), currentPage (copy), u8733 (copy), u8732 (copy), EVENT_TYPES (ref), u8734 (copy), FFlagKidsNotApprovedPageTreatment (ref), u8736 (copy), u8727 (ref), currentPageName (copy)
                if u8735.current then
                    u8735.current = false;

                    return;
                end;

                if currentPage == u8733.current then
                    return;
                end;

                local v8738 = DateTime.now().UnixTimestampMillis - u8732.current;
                local v8739;

                if currentPage > u8733.current then
                    v8739 = EVENT_TYPES.ContinueClicked;
                else
                    v8739 = EVENT_TYPES.BackClicked;
                end;

                local v8740 = {
                    eventType = v8739,
                    pageName = u8734.current,
                    timeOnPageMs = v8738
                };

                if FFlagKidsNotApprovedPageTreatment then
                    v8740.isKidsTreatment = tostring(u8736);
                end;

                u8727(v8740);
                u8732.current = DateTime.now().UnixTimestampMillis;
                u8733.current = currentPage;
                u8734.current = currentPageName;
            end, { currentPage, currentPageName, u8736 });
            local u8745 = useCallback(function(p8741, p8742) -- Line: 59861
                -- upvalues: u8732 (copy), u8726 (ref), currentPageName (copy), FFlagKidsNotApprovedPageTreatment (ref), u8736 (copy), u8727 (ref)
                local v8743 = DateTime.now().UnixTimestampMillis - u8732.current;
                local v8744 = u8726.Dictionary.join({
                    eventType = p8741,
                    pageName = currentPageName,
                    timeOnPageMs = v8743
                }, p8742 or {});

                if FFlagKidsNotApprovedPageTreatment then
                    v8744.isKidsTreatment = tostring(u8736);
                end;

                u8727(v8744);
            end, { currentPageName, u8736 });
            local v8746 = useMemo(function() -- Line: 59876
                -- upvalues: u8745 (copy)
                return {
                    sendPageEvent = u8745
                };
            end, { u8745 });

            return u8728.createElement(u8729.Provider, {
                value = v8746
            }, p8730.children);
        end,

        usePageAnalytics = function() -- Line: 59884, Name: usePageAnalytics
            -- upvalues: useContext (copy), u8729 (copy), u8725 (copy)
            local v8747 = useContext(u8729);
            local v8748;

            if v8747 then
                v8748 = v8747.sendPageEvent ~= nil;
            else
                v8748 = v8747;
            end;

            u8725.assert(v8748, "usePageAnalytics must be used within PageAnalyticsProvider (which must also be nested inside PageNavigationProvider)");

            return v8747;
        end
    };
end;

function u2.fPe() -- Line: 59901
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8749 = u2.loadModule("fPf");
    local View = u2.loadModule("fPg").View;
    local usePageAnalytics = u2.loadModule("fPh").usePageAnalytics;
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;
    local useDispatch = u2.loadModule("fPP").Hooks.RoactRodux.useDispatch;

    return u8749.memo(function(p8750) -- Line: 59921, Name: CtaButtonsContainer
        -- upvalues: usePageNavigation (copy), usePageAnalytics (copy), useDispatch (copy), u8749 (copy), View (copy)
        local v8751 = usePageNavigation();
        local v8752 = usePageAnalytics();
        local v8753 = useDispatch();
        local CurrentCtaComponent = v8751.CurrentCtaComponent;

        if CurrentCtaComponent then
            return u8749.createElement(View, {
                tag = "size-full-0 auto-y col gap-medium padding-x-xxlarge padding-bottom-xxlarge padding-top-medium"
            }, u8749.createElement(CurrentCtaComponent, {
                key = v8751.currentPageName,
                moderationDetail = p8750.moderationDetail,
                dispatch = v8753,
                LogoutThunk = p8750.LogoutThunk,
                goToNextPage = v8751.goToNextPage,
                sendPageEvent = v8752.sendPageEvent,
                hasNavigatedForward = v8751.hasNavigatedForward
            }));
        end;

        return nil;
    end);
end;

function u2.fQA() -- Line: 59966
    -- upvalues: u2 (ref)
    local u8755 = u2.loadModule("fPf");
    local v8756 = u2.loadModule("fPg");
    local ButtonSize = v8756.Enums.ButtonSize;
    local ButtonVariant = v8756.Enums.ButtonVariant;
    local IconButton = v8756.IconButton;
    local IconName = v8756.Enums.IconName;
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;

    return u8755.memo(function() -- Line: 59981, Name: BackButton
        -- upvalues: usePageNavigation (copy), u8755 (copy), IconButton (copy), IconName (copy), ButtonVariant (copy), ButtonSize (copy)
        local v8757 = usePageNavigation();

        return u8755.createElement(IconButton, {
            testId = "back-button",
            icon = IconName.ChevronLargeLeft,
            variant = ButtonVariant.Utility,
            onActivated = v8757.goToPreviousPage,
            size = ButtonSize.Medium
        });
    end);
end;

function u2.fQB() -- Line: 60055
    -- upvalues: u2 (ref)
    local VRService = game:GetService("VRService");
    local u8766 = u2.loadModule("fPf");
    local useCallback = u8766.useCallback;
    local useEffect = u8766.useEffect;
    local useMemo = u8766.useMemo;
    local useRef = u8766.useRef;
    local useState = u8766.useState;
    local v8767 = u2.loadModule("fPg");
    local Button = v8767.Button;
    local ButtonSize = v8767.Enums.ButtonSize;
    local ButtonVariant = v8767.Enums.ButtonVariant;
    local IconButton = v8767.IconButton;
    local IconName = v8767.Enums.IconName;
    local OverlayProvider = v8767.OverlayProvider;
    local PopoverSide = v8767.Enums.PopoverSide;
    local PopoverAlign = v8767.Enums.PopoverAlign;
    local Popover = v8767.Popover;
    local Radius = v8767.Enums.Radius;
    local useTokens = v8767.Hooks.useTokens;
    local View = v8767.View;
    local v8768 = u2.loadModule("fQe");
    local FocusNavigableSurfaceIdentifierEnum = v8768.FocusNavigableSurfaceIdentifierEnum;
    local FocusNavigationEventNameEnum = v8768.FocusNavigationEventNameEnum;
    local useAppFocusRoot = v8768.useAppFocusRoot;
    local u8769 = u2.loadModule("fQg");
    local u8770 = u2.loadModule("fQi");
    u2.loadModule("fQf");
    local u8771 = u2.loadModule("fQC");
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;

    return u8766.memo(function(p8772) -- Line: 60098, Name: HeaderPopoverMenu
        -- upvalues: useTokens (copy), useNotApprovedPageContext (copy), useState (copy), u8771 (copy), useRef (copy), VRService (copy), u8769 (copy), useMemo (copy), FocusNavigationEventNameEnum (copy), u8770 (copy), useAppFocusRoot (copy), FocusNavigableSurfaceIdentifierEnum (copy), useCallback (copy), useEffect (copy), u8766 (copy), OverlayProvider (copy), Popover (copy), IconButton (copy), IconName (copy), ButtonVariant (copy), ButtonSize (copy), PopoverSide (copy), PopoverAlign (copy), Radius (copy), View (copy), Button (copy)
        local v8773 = useTokens();
        local translations = useNotApprovedPageContext().translations;
        local v8774, v8775 = useState(false);
        local v8776, u8777 = useState(false);
        local u8778 = u8771(v8775, p8772.LogoutThunk);
        local u8779 = useRef(nil);
        local v8780;

        if VRService.VREnabled then
            v8780 = u8769();
        else
            v8780 = nil;
        end;

        local v8782 = useMemo(function() -- Line: 60110
            -- upvalues: FocusNavigationEventNameEnum (ref), u8770 (ref), u8777 (copy)
            return {
                [FocusNavigationEventNameEnum.NavigateBack] = {
                    handler = u8770.onRelease(function(p8781) -- Line: 60113
                        -- upvalues: u8777 (ref)
                        p8781.cancelled = true;
                        u8777(false);
                    end)
                }
            };
        end, { u8777 });
        local u8783 = useAppFocusRoot({
            surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.ContextualMenu,
            isFocusable = v8776,
            customEventHandlers = v8782
        });
        local v8785 = useCallback(function(p8784) -- Line: 60133
            -- upvalues: u8779 (copy), u8783 (copy)
            u8779.current = p8784;

            if type(u8783) == "function" then
                u8783(p8784);
            end;
        end, { u8783 });
        useEffect(function() -- Line: 60141
            -- upvalues: u8779 (copy)
            if u8779 and u8779.current then
                u8779.current.SelectionBehaviorDown = Enum.SelectionBehavior.Stop;
                u8779.current.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop;
                u8779.current.SelectionBehaviorRight = Enum.SelectionBehavior.Stop;
                u8779.current.SelectionBehaviorUp = Enum.SelectionBehavior.Stop;
                u8779.current.SelectionGroup = true;
            end;
        end, { v8776 });
        local v8787 = useCallback(function() -- Line: 60151
            -- upvalues: u8777 (copy)
            u8777(function(p8786) -- Line: 60152
                return not p8786;
            end);
        end, {});
        local u8788 = useCallback(function() -- Line: 60157
            -- upvalues: u8777 (copy)
            u8777(false);
        end, {});
        local v8789 = useCallback(function() -- Line: 60161
            -- upvalues: u8788 (copy), u8778 (copy)
            u8788();
            u8778();
        end, { u8778, u8788 });

        return u8766.createElement(OverlayProvider, {
            gui = v8780
        }, {
            PopoverMenu = u8766.createElement(Popover.Root, {
                isOpen = v8776
            }, {
                Anchor = u8766.createElement(Popover.Anchor, nil, {
                    MenuButton = u8766.createElement(IconButton, {
                        testId = "header-menu-button",
                        icon = IconName.ThreeDotsVertical,
                        variant = ButtonVariant.Utility,
                        onActivated = v8787,
                        size = ButtonSize.Medium
                    })
                }),
                Content = u8766.createElement(Popover.Content, {
                    hasArrow = false,
                    side = {
                        position = PopoverSide.Bottom,
                        offset = v8773.Padding.Small
                    },
                    align = PopoverAlign.End,
                    backgroundStyle = v8773.Color.Surface.Surface_100,
                    radius = Radius.Medium,
                    onPressedOutside = u8788
                }, {
                    MenuContent = u8766.createElement(View, {
                        tag = "auto-xy radius-medium bg-surface-100 stroke-standard stroke-default padding-small",
                        ref = v8785
                    }, {
                        LogoutButton = u8766.createElement(Button, {
                            text = translations.logoutButton,
                            onActivated = v8789,
                            isDisabled = v8774,
                            isLoading = v8774,
                            variant = ButtonVariant.Utility,
                            size = ButtonSize.Small
                        })
                    })
                })
            })
        });
    end);
end;

function u2.fQE() -- Line: 60215
    -- upvalues: u2 (ref)
    local u8790 = u2.loadModule("fPf");
    local v8791 = u2.loadModule("fPg");
    local Progress = v8791.Progress;
    local ProgressShape = v8791.Enums.ProgressShape;
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;

    return u8790.memo(function() -- Line: 60229, Name: HeaderProgressBar
        -- upvalues: usePageNavigation (copy), u8790 (copy), Progress (copy), ProgressShape (copy)
        local Progress2 = usePageNavigation().getProgress();

        return Progress2 > 0 and u8790.createElement(Progress, {
            testId = "header-progress-bar",
            value = Progress2,
            shape = ProgressShape.Bar
        }) or nil;
    end);
end;

function u2.fQz() -- Line: 60245
    -- upvalues: u2 (ref)
    local u8792 = u2.loadModule("fPf");
    local v8793 = u2.loadModule("fPg");
    local Icon = v8793.Icon;
    local IconSize = v8793.Enums.IconSize;
    local Text = v8793.Text;
    local useTokens = v8793.Hooks.useTokens;
    local View = v8793.View;
    local v8794 = u2.loadModule("fQn");
    local CircleSlash = v8794.Icon.CircleSlash;
    local IconVariant = v8794.IconVariant;
    local TriangleExclamation = v8794.Icon.TriangleExclamation;
    local u8795 = u2.loadModule("fQA");
    local u8796 = u2.loadModule("fQB");
    local u8797 = u2.loadModule("fQE");
    u2.loadModule("fPc");
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;
    local useNotApprovedPageContext = u2.loadModule("fPB").useNotApprovedPageContext;
    local Constants = u2.loadModule("fPa").Constants;
    local INTERVENTION_TYPES = Constants.INTERVENTION_TYPES;
    local PUNISHMENT_TYPE_TO_INTERVENTION_MAP = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP;

    return u8792.memo(function(p8798) -- Line: 60279, Name: Header
        -- upvalues: useTokens (copy), usePageNavigation (copy), useNotApprovedPageContext (copy), PUNISHMENT_TYPE_TO_INTERVENTION_MAP (copy), INTERVENTION_TYPES (copy), CircleSlash (copy), TriangleExclamation (copy), u8792 (copy), View (copy), Icon (copy), IconSize (copy), IconVariant (copy), Text (copy), u8796 (copy), u8795 (copy), u8797 (copy)
        local v8799 = useTokens();
        local v8800 = usePageNavigation();
        local translations = useNotApprovedPageContext().translations;
        local totalPages = v8800.totalPages;
        local punishmentTypeDescription = p8798.moderationDetail.punishmentTypeDescription;
        local verificationCategory = p8798.moderationDetail.verificationCategory;
        local v8801 = PUNISHMENT_TYPE_TO_INTERVENTION_MAP[punishmentTypeDescription] or INTERVENTION_TYPES.Banned;

        if verificationCategory then
            verificationCategory = verificationCategory ~= "";
        end;

        local v8802;

        if verificationCategory then
            v8802 = translations.genericSuspended;
        else
            v8802 = translations[punishmentTypeDescription];
        end;

        if not v8802 or v8802 == "" then
            v8802 = translations.genericSuspended;
        end;

        local v8803;

        if v8801 == INTERVENTION_TYPES.Deleted then
            v8803 = CircleSlash;
        else
            v8803 = TriangleExclamation;
        end;

        local v8804;

        if v8801 == INTERVENTION_TYPES.Warning and not verificationCategory then
            v8804 = v8799.Color.System.Warning;
        else
            v8804 = v8799.Color.System.Alert;
        end;

        if v8800.isFirstPage then
            return u8792.createElement(View, {
                tag = "size-full-0 auto-y row flex-between items-center gap-medium padding-xxlarge"
            }, {
                LeftContent = u8792.createElement(View, {
                    tag = "auto-xy row gap-small items-center wrap shrink",
                    LayoutOrder = 1
                }, {
                    PunishmentIcon = u8792.createElement(Icon, {
                        LayoutOrder = 1,
                        name = v8803,
                        size = IconSize.Large,
                        variant = IconVariant.Regular,
                        style = v8804
                    }),
                    PunishmentLabel = u8792.createElement(Text, {
                        tag = "auto-xy text-heading-small content-emphasis text-wrap text-align-x-left",
                        LayoutOrder = 2,
                        Text = v8802
                    })
                }),
                RightContent = u8792.createElement(View, {
                    tag = "auto-xy shrink-0",
                    LayoutOrder = 2
                }, {
                    PopoverMenu = u8792.createElement(u8796, {
                        LogoutThunk = p8798.LogoutThunk
                    })
                })
            });
        end;

        local createElement = u8792.createElement;
        local v8805 = {
            tag = "size-full-0 auto-y col gap-xlarge items-start padding-y-xxlarge padding-right-xxlarge"
        };
        local v8806 = {
            BackButtonContainer = u8792.createElement(View, {
                tag = "auto-xy padding-left-medium",
                LayoutOrder = 1
            }, {
                BackButton = u8792.createElement(u8795)
            })
        };
        local v8807;

        if totalPages > 2 then
            v8807 = u8792.createElement(View, {
                tag = "size-full-0 auto-y padding-left-xxlarge",
                LayoutOrder = 2
            }, {
                ProgressBar = u8792.createElement(u8797)
            });
        else
            v8807 = false;
        end;

        v8806.ProgressBarContainer = v8807;

        return createElement(View, v8805, v8806);
    end);
end;

function u2.fQF() -- Line: 60369
    -- upvalues: u2 (ref)
    local GuiService = game:GetService("GuiService");
    local UserInputService = game:GetService("UserInputService");
    local u8808 = u2.loadModule("fPf");
    local v8809 = u2.loadModule("fPg");
    local Radius = v8809.Enums.Radius;
    local ScrollBarVisibility = v8809.Enums.ScrollBarVisibility;
    local ScrollView = v8809.ScrollView;
    local Skeleton = v8809.Skeleton;
    local useTokens = v8809.Hooks.useTokens;
    local View = v8809.View;
    local u8810 = u2.loadModule("fPO");
    local usePreferredInput = u8810.usePreferredInput;

    return u8808.memo(function() -- Line: 60390, Name: LoadingSkeleton
        -- upvalues: useTokens (copy), usePreferredInput (copy), u8810 (copy), UserInputService (copy), GuiService (copy), u8808 (copy), View (copy), Skeleton (copy), Radius (copy), ScrollView (copy), ScrollBarVisibility (copy)
        local v8811 = useTokens();
        local v8812 = usePreferredInput() == u8810.Input.Directional;
        local Y = UserInputService.StatusBarSize.Y;
        local Y2 = UserInputService.BottomBarSize.Y;
        local bottom = GuiService:GetSafeZoneOffsets().bottom;

        if Y2 ~= 0 then
            bottom = Y2;
        end;

        local createElement = u8808.createElement;
        local v8813 = {
            tag = "size-full col align-x-center align-y-center bg-surface-0",
            padding = {
                top = UDim.new(0, Y),
                bottom = UDim.new(0, bottom)
            }
        };
        local v8814 = {};
        local createElement2 = u8808.createElement;
        local v8815 = {
            tag = "size-full col gap-large bg-surface-100 radius-large",
            LayoutOrder = 1
        };
        local v8816 = {};
        local v8817;

        if v8812 then
            v8817 = Vector2.new(800, 1000);
        else
            v8817 = Vector2.new(600, 800);
        end;

        v8816.MaxSize = v8817;
        v8815.sizeConstraint = v8816;
        v8814.InnerContainer = createElement2(View, v8815, {
            HeaderSection = u8808.createElement(View, {
                tag = "size-full-0 auto-y row flex-between items-center gap-medium padding-xxlarge",
                LayoutOrder = 1
            }, {
                LeftContent = u8808.createElement(View, {
                    tag = "auto-xy row gap-small items-center",
                    LayoutOrder = 1
                }, {
                    IconSkeleton = u8808.createElement(Skeleton, {
                        LayoutOrder = 1,
                        Size = UDim2.new(0, v8811.Size.Size_800, 0, v8811.Size.Size_800),
                        radius = Radius.Circle
                    }),
                    LabelSkeleton = u8808.createElement(Skeleton, {
                        LayoutOrder = 2,
                        Size = UDim2.new(0, v8811.Size.Size_3000, 0, v8811.Size.Size_700),
                        radius = Radius.Medium
                    })
                }),
                RightContent = u8808.createElement(View, {
                    tag = "auto-xy",
                    LayoutOrder = 2
                }, {
                    MenuSkeleton = u8808.createElement(Skeleton, {
                        Size = UDim2.new(0, v8811.Size.Size_800, 0, v8811.Size.Size_800),
                        radius = Radius.Circle
                    })
                })
            }),
            Content = u8808.createElement(View, {
                tag = "size-full-0 grow",
                LayoutOrder = 2
            }, {
                ScrollView = u8808.createElement(ScrollView, {
                    tag = "size-full",
                    scroll = {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        CanvasSize = UDim2.new(1, 0, 1, 0),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        VerticalScrollBarInset = Enum.ScrollBarInset.None,
                        scrollBarVisibility = ScrollBarVisibility.Always
                    }
                }, {
                    Content = u8808.createElement(View, {
                        tag = "size-full-0 auto-y col gap-xlarge padding-x-xxlarge"
                    }, {
                        PunishmentDescription = u8808.createElement(Skeleton, {
                            LayoutOrder = 1,
                            Size = UDim2.new(0.8, 0, 0, v8811.Size.Size_500),
                            radius = Radius.Medium
                        }),
                        WhatHappened = u8808.createElement(View, {
                            tag = "size-full-0 auto-y col gap-medium",
                            LayoutOrder = 2
                        }, {
                            Title = u8808.createElement(Skeleton, {
                                LayoutOrder = 1,
                                Size = UDim2.new(0.25, 0, 0, v8811.Size.Size_700),
                                radius = Radius.Medium
                            }),
                            Content = u8808.createElement(Skeleton, {
                                LayoutOrder = 2,
                                Size = UDim2.new(1, 0, 0, v8811.Size.Size_2500),
                                radius = Radius.Medium
                            })
                        }),
                        ReviewedEvidence = u8808.createElement(View, {
                            tag = "size-full-0 auto-y col gap-medium",
                            LayoutOrder = 3
                        }, {
                            Title = u8808.createElement(Skeleton, {
                                LayoutOrder = 1,
                                Size = UDim2.new(0.25, 0, 0, v8811.Size.Size_700),
                                radius = Radius.Medium
                            }),
                            Content = u8808.createElement(Skeleton, {
                                LayoutOrder = 2,
                                Size = UDim2.new(1, 0, 0, v8811.Size.Size_3000),
                                radius = Radius.Medium
                            })
                        })
                    })
                })
            }),
            Footer = u8808.createElement(View, {
                tag = "size-full-0 auto-y padding-x-xxlarge padding-bottom-xxlarge padding-top-medium bg-surface-100 radius-large",
                LayoutOrder = 3
            }, {
                TopCornerCover = u8808.createElement("Frame", {
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, v8811.Radius.Large),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundColor3 = v8811.Color.Surface.Surface_100.Color3
                }),
                ButtonSkeleton = u8808.createElement(Skeleton, {
                    Size = UDim2.new(1, 0, 0, v8811.Size.Size_1100),
                    radius = Radius.Medium
                })
            })
        });

        return createElement(View, v8813, v8814);
    end);
end;

function u2.fQG() -- Line: 60539
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local u8818 = u2.loadModule("fPf");
    local useDispatch = u2.loadModule("fPP").Hooks.RoactRodux.useDispatch;
    local useEffect = u8818.useEffect;
    local useRef = u8818.useRef;
    local v8819 = u2.loadModule("fPg");
    local View = v8819.View;
    local ScrollView = v8819.ScrollView;
    local ScrollBarVisibility = v8819.Enums.ScrollBarVisibility;
    local renderPageItemsFromList = u2.loadModule("fPj").renderPageItemsFromList;
    local usePageNavigation = u2.loadModule("fPl").usePageNavigation;

    return u8818.memo(function(p8820) -- Line: 60567, Name: PageItemsFromConfigs
        -- upvalues: useDispatch (copy), useRef (copy), usePageNavigation (copy), renderPageItemsFromList (copy), useEffect (copy), u8818 (copy), ScrollView (copy), ScrollBarVisibility (copy), View (copy)
        local v8821 = useDispatch();
        local u8822 = useRef(nil);
        local moderationDetail = p8820.moderationDetail;
        local v8823 = usePageNavigation();
        local currentPage = v8823.currentPage;
        local v8824 = renderPageItemsFromList(v8823.currentPageConfigs, moderationDetail, v8821, v8823.currentPage, v8823.hasEducationalPages, v8823.isFirstPage, v8823.currentPageName, p8820.commutationEligibility);
        useEffect(function() -- Line: 60588
            -- upvalues: u8822 (copy)
            local v8825 = u8822.current and u8822.current:FindFirstChildWhichIsA("ScrollingFrame", true);

            if v8825 then
                v8825.CanvasPosition = Vector2.new(0, 0);
            end;
        end, { currentPage });

        return u8818.createElement(ScrollView, {
            tag = "size-full",
            ref = u8822,
            scroll = {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(1, 0, 1, 0),
                ScrollingDirection = Enum.ScrollingDirection.Y,
                VerticalScrollBarInset = Enum.ScrollBarInset.None,
                scrollBarVisibility = ScrollBarVisibility.Always
            }
        }, {
            Content = u8818.createElement(View, {
                tag = "size-full-0 auto-y col"
            }, {
                PageItemsContent = u8818.createElement(View, {
                    tag = "size-full-0 auto-y col gap-xlarge padding-x-xxlarge",
                    LayoutOrder = 2
                }, unpack(v8824))
            })
        });
    end);
end;

function u2.fQH() -- Line: 60623
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");

    return function(p8826, p8827) -- Line: 60628, Name: setBadUtterancesTranslationKeys
        for _, v in p8826.badUtterances do
            local labelTranslationKey = v.labelTranslationKey;

            if labelTranslationKey then
                p8827[labelTranslationKey] = "Feature.NotApproved." .. labelTranslationKey;
            end;
        end;
    end;
end;

function u2.fQI() -- Line: 60646
    -- upvalues: u2 (ref)
    u2.loadModule("fPc");
    local VIOLATION_TYPE_TO_PLURAL_MAP = u2.loadModule("fPa").Constants.VIOLATION_TYPE_TO_PLURAL_MAP;
    local u8828 = u2.loadModule("fPw");
    local u8829 = u2.loadModule("fPy");

    return function(p8830, p8831) -- Line: 60658, Name: setViolationEvidenceTranslationKeys
        -- upvalues: u8828 (copy), u8829 (copy), VIOLATION_TYPE_TO_PLURAL_MAP (copy)
        local violation = p8830.violation;

        if not (violation and u8828.isVisibleInView(violation)) then
            return;
        end;

        local evidence = violation.evidence;

        for _, v in evidence.elements or {} do
            if v.labelKey then
                p8831[v.labelKey] = "Feature.AppealsPortal." .. v.labelKey;
            end;

            if v.altLabelKey then
                p8831[v.altLabelKey] = "Feature.AppealsPortal." .. v.altLabelKey;
            end;

            if u8829 and v.textKey then
                local v8832 = v.textKey .. "_" .. v.labelKey;

                if v.textKeyParameters then
                    local v8833 = { "Feature.NotApproved." .. v.textKey };

                    for i, v2 in v.textKeyParameters do
                        v8833[i] = v2;
                    end;

                    p8831[v8832] = v8833;
                else
                    p8831[v8832] = "Feature.NotApproved." .. v.textKey;
                end;
            end;
        end;

        for _, v in violation.abuseTypeTranslationKeys do
            p8831[v] = "Feature.NotApproved." .. v;
        end;

        if evidence.displayMeta then
            local capitalizedKey = evidence.displayMeta.capitalizedKey;

            if capitalizedKey and capitalizedKey ~= "" then
                p8831.violationType = VIOLATION_TYPE_TO_PLURAL_MAP[capitalizedKey];
            end;
        end;
    end;
end;

function u2.fQK() -- Line: 60735
    return __DefineFastFlag("NapKidsIXPExposure", false);
end;

function u2.fOX() -- Line: 60739
    -- upvalues: u2 (ref)
    local GuiService = game:GetService("GuiService");
    local IXPService = game:GetService("IXPService");
    local UserInputService = game:GetService("UserInputService");
    local AppUserLayers = u2.loadModule("fOY").AppUserLayers;
    local u8834 = u2.loadModule("fOZ");
    local Constants = u2.loadModule("fPa").Constants;
    local u8835 = u2.loadModule("fPd");
    local u8836 = u2.loadModule("fPe");
    local u8837 = u2.loadModule("fQy");
    local u8838 = u2.loadModule("fQz");
    local u8839 = u2.loadModule("fPs");
    local u8840 = u2.loadModule("fQF");
    local NotApprovedPageProvider = u2.loadModule("fPB").NotApprovedPageProvider;
    local PageAnalyticsProvider = u2.loadModule("fPh").PageAnalyticsProvider;
    local u8841 = u2.loadModule("fQG");
    local PageNavigationProvider = u2.loadModule("fPl").PageNavigationProvider;
    local RoactNetworking = u2.loadModule("fPM").RoactNetworking;
    local u8842 = u2.loadModule("fPk");
    local u8843 = u2.loadModule("fQH");
    local u8844 = u2.loadModule("fQI");
    u2.loadModule("fPc");
    local u8845 = u2.loadModule("fPf");
    local useEffect = u8845.useEffect;
    local useState = u8845.useState;
    local useAppPolicy = u2.loadModule("fQJ").useAppPolicy;
    local useLocalization = u2.loadModule("fPA").Hooks.useLocalization;
    local useRoactService = u2.loadModule("fPN").useRoactService;
    local u8846 = u2.loadModule("fPO");
    local usePreferredInput = u8846.usePreferredInput;
    local View = u2.loadModule("fPg").View;
    local v8847 = u2.loadModule("fPq");
    local FFlagKidsNotApprovedPageTreatment = v8847.FFlagKidsNotApprovedPageTreatment;
    local FFlagNotApprovedPageIXPExposure = v8847.FFlagNotApprovedPageIXPExposure;
    local u8848 = u2.loadModule("fQK");
    local EVENT_TYPES = Constants.EVENT_TYPES;
    local TRANSLATION_KEYS = Constants.TRANSLATION_KEYS;

    return u8845.memo(function(p8849) -- Line: 60796, Name: NotApprovedPageV2
        -- upvalues: useState (copy), FFlagKidsNotApprovedPageTreatment (copy), u8848 (copy), useAppPolicy (copy), UserInputService (copy), GuiService (copy), useRoactService (copy), RoactNetworking (copy), usePreferredInput (copy), u8846 (copy), useEffect (copy), u8837 (copy), FFlagNotApprovedPageIXPExposure (copy), IXPService (copy), AppUserLayers (copy), EVENT_TYPES (copy), u8834 (copy), u8842 (copy), u8835 (copy), TRANSLATION_KEYS (copy), u8839 (copy), u8843 (copy), u8844 (copy), useLocalization (copy), u8845 (copy), u8836 (copy), u8840 (copy), NotApprovedPageProvider (copy), PageNavigationProvider (copy), PageAnalyticsProvider (copy), View (copy), u8838 (copy), u8841 (copy)
        local v8850, u8851 = useState(true);
        local v8852, u8853 = useState(nil);
        local u8854;

        if FFlagKidsNotApprovedPageTreatment or u8848 then
            u8854 = useAppPolicy(function(p8855) -- Line: 60802
                local getAccountType = p8855.getAccountType;

                if getAccountType then
                    return getAccountType();
                end;

                return nil;
            end);
        else
            u8854 = nil;
        end;

        local u8856 = FFlagKidsNotApprovedPageTreatment and u8854 == "Kids";
        local Y = UserInputService.StatusBarSize.Y;
        local Y2 = UserInputService.BottomBarSize.Y;
        local bottom = GuiService:GetSafeZoneOffsets().bottom;

        if Y2 == 0 then
            Y2 = bottom;
        end;

        local moderationDetail = p8849.moderationDetail;
        local interventionType = p8849.interventionType;
        local u8857 = useRoactService(RoactNetworking);
        local v8858 = usePreferredInput() == u8846.Input.Directional;
        useEffect(function() -- Line: 60822
            -- upvalues: u8837 (ref), u8857 (copy), u8853 (copy), u8851 (copy)
            u8837(u8857):andThen(function(p8859) -- Line: 60824
                -- upvalues: u8853 (ref)
                if p8859.responseBody then
                    u8853(p8859.responseBody);
                end;
            end):catch(function(p8860) -- Line: 60829
                -- upvalues: u8853 (ref)
                u8853({
                    educational_pass_eligible = false
                });
            end):finally(function() -- Line: 60835
                -- upvalues: u8851 (ref)
                u8851(false);
            end);
        end, { u8857 });
        useEffect(function() -- Line: 60840
            -- upvalues: u8848 (ref), u8854 (ref), FFlagNotApprovedPageIXPExposure (ref), IXPService (ref), AppUserLayers (ref), EVENT_TYPES (ref), moderationDetail (copy), u8834 (ref), interventionType (copy), FFlagKidsNotApprovedPageTreatment (ref), u8856 (copy), u8842 (ref)
            local v8861;

            if u8848 then
                v8861 = u8854 == "Kids";
            else
                v8861 = FFlagNotApprovedPageIXPExposure;
            end;

            if v8861 and __GetEngineFeature("EnableLogFlagLinkedUserLayerExposure") then
                IXPService:LogFlagLinkedUserLayerExposure(AppUserLayers.NotApprovedPageUserIDLayer);
            end;

            local v8862 = {
                eventType = EVENT_TYPES.PageRendered,
                interventionId = moderationDetail.interventionId,
                verificationCategory = moderationDetail.verificationCategory,
                isReactivationEligible = tostring(u8834(interventionType, moderationDetail.endDate, moderationDetail.verificationCategory)),
                punishedUserId = moderationDetail.punishedUserId
            };

            if FFlagKidsNotApprovedPageTreatment then
                v8862.isKidsTreatment = tostring(u8856);
            end;

            u8842(v8862);
        end, {
            interventionType,
            moderationDetail.endDate,
            moderationDetail.verificationCategory,
            moderationDetail.interventionId,
            moderationDetail.punishedUserId,
            u8854,
            u8856
        });
        local v8863;

        if u8856 then
            v8863 = u8835.Dictionary.join(TRANSLATION_KEYS, u8839.TRANSLATION_KEYS);
        else
            v8863 = TRANSLATION_KEYS;
        end;

        u8843(moderationDetail, v8863);
        u8844(moderationDetail, v8863);
        local v8864 = useLocalization(v8863);
        local v8865 = u8845.createElement(u8836, {
            moderationDetail = moderationDetail,
            LogoutThunk = p8849.LogoutThunk
        });

        if v8850 then
            return u8845.createElement(u8840);
        end;

        local createElement = u8845.createElement;
        local v8866 = {
            translations = v8864,
            moderationDetail = moderationDetail,
            commutationEligibility = v8852,
            isKidsTreatment = u8856
        };
        local createElement2 = u8845.createElement;
        local v8867 = {
            moderationDetail = moderationDetail
        };
        local createElement3 = u8845.createElement;
        local v8868 = {
            isKidsTreatment = u8856
        };
        local createElement4 = u8845.createElement;
        local v8869 = {
            tag = "col align-x-center align-y-center size-full bg-surface-0",
            padding = {
                top = UDim.new(0, Y),
                bottom = UDim.new(0, Y2)
            }
        };
        local v8870 = {};
        local createElement5 = u8845.createElement;
        local v8871 = {
            tag = "col size-full stroke-standard stroke-default radius-large bg-surface-100",
            LayoutOrder = 1
        };
        local v8872 = {};
        local v8873;

        if v8858 then
            v8873 = Vector2.new(800, 1000);
        else
            v8873 = Vector2.new(600, 800);
        end;

        v8872.MaxSize = v8873;
        v8871.sizeConstraint = v8872;
        v8870.InnerContainer = createElement5(View, v8871, {
            HeaderSection = u8845.createElement(u8838, {
                LayoutOrder = 1,
                moderationDetail = moderationDetail,
                LogoutThunk = p8849.LogoutThunk
            }),
            Content = u8845.createElement(View, {
                tag = "col grow size-full-0",
                LayoutOrder = 2
            }, u8845.createElement(u8841, {
                moderationDetail = moderationDetail,
                LogoutThunk = p8849.LogoutThunk,
                commutationEligibility = v8852
            })),
            Footer = u8845.createElement(View, {
                tag = "col size-full-0 auto-y",
                LayoutOrder = 3
            }, {
                FooterContent = v8865
            })
        });

        return createElement(NotApprovedPageProvider, v8866, createElement2(PageNavigationProvider, v8867, createElement3(PageAnalyticsProvider, v8868, createElement4(View, v8869, v8870))));
    end);
end;

-- mount ---------------------------------------------------------------------------------
local ok, err = pcall(function()
	local NotApprovedPageV2 = u2.loadModule("fOX")
	local Constants = u2.__fKI()

	local now = os.time()
	local beginTs = now - CONFIG.reviewedAgoSeconds
	local moderationDetail = {
		punishedUserId = Players.LocalPlayer and Players.LocalPlayer.UserId or 0,
		punishmentId = 0,
		interventionId = CONFIG.interventionId or HttpService:GenerateGUID(false):lower(),
		punishmentTypeDescription = CONFIG.punishmentType,
		messageToUser = CONFIG.moderatorNote,
		beginDate = DateTime.fromUnixTimestamp(beginTs):ToIsoDate(),
		endDate = DateTime.fromUnixTimestamp(beginTs + CONFIG.durationSeconds):ToIsoDate(),
		badUtterances = {},
		violation = nil,
		labelTranslationKey = "",
		verificationCategory = "",
		consequenceTransparencyMessage = "",
		showAppealsProcessLink = false,
		isForeshadowingConsequenceEnabled = false,
		showUGCAvatarGuidelinesLink = false,
		context = {},
	}

	local ErrorBoundary = React.Component:extend("BanPageErrorBoundary")
	function ErrorBoundary:init() self.state = { message = nil } end
	function ErrorBoundary.getDerivedStateFromError(e) return { message = tostring(e) } end
	function ErrorBoundary:componentDidCatch(e, info)
		log("render error:", tostring(e))
		if info and info.componentStack then log(info.componentStack) end
	end
	function ErrorBoundary:render()
		if self.state.message then
			return React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), TextColor3 = Color3.new(0.7, 0, 0),
				TextWrapped = true, TextSize = 16, Text = "Page failed to render (see ban_page_log.txt):\n" .. self.state.message,
			})
		end
		return self.props.children
	end

	local UserGameSettings = UserSettings():GetService("UserGameSettings")
	local Enums = Foundation.Enums
	local tree = React.createElement(ErrorBoundary, nil, {
		Foundation = React.createElement(Foundation.FoundationProvider, {
			colorMode = Enums.ColorMode and Enums.ColorMode[CONFIG.colorMode == "Auto" and detectColorMode() or CONFIG.colorMode] or nil,
			device = Enums.Device and Enums.Device.Desktop or nil,
			preferences = {
				preferredTransparency = UserGameSettings.PreferredTransparency,
				reducedMotion = UserGameSettings.ReducedMotion,
				preferredTextSize = UserGameSettings.PreferredTextSize,
			},
		}, {
			Page = React.createElement(NotApprovedPageV2, {
				moderationDetail = moderationDetail,
				interventionType = Constants.PUNISHMENT_TYPE_TO_INTERVENTION_MAP[CONFIG.punishmentType],
				LogoutThunk = function() return function() end end,
			}),
		}),
	})

	for _, root in { (gethui and gethui()) or nil, game:GetService("CoreGui") } do
		pcall(function()
			local old = root:FindFirstChild("BanPagePreview")
			if old then old:Destroy() end
		end)
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "BanPagePreview"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local parented = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
	if not parented or not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

	local coreStates = {}
	for _, t in Enum.CoreGuiType:GetEnumItems() do
		if t ~= Enum.CoreGuiType.All then
			local okS, on = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, t)
			if okS then coreStates[t] = on end
		end
	end
	pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.All, false)

	local root = ReactRoblox.createRoot(gui)
	root:render(tree)
	log("mounted")

	local modalGui = Instance.new("ScreenGui")
	modalGui.Name = "BanPagePreviewModal"
	modalGui.ResetOnSpawn = false
	local modal = Instance.new("TextButton")
	modal.Modal = true
	modal.BackgroundTransparency = 1
	modal.Text = ""
	modal.Size = UDim2.fromOffset(0, 0)
	modal.Parent = modalGui
	pcall(function() modalGui.Parent = gui.Parent end)
	local mouseWas = { behavior = UIS.MouseBehavior, icon = UIS.MouseIconEnabled }
	local mouseConn = game:GetService("RunService").RenderStepped:Connect(function()
		if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
		if not UIS.MouseIconEnabled then UIS.MouseIconEnabled = true end
	end)

	local CoreGui = game:GetService("CoreGui")
	local protected = { gui, modalGui }
	local function holdsPage(c)
		for _, p in protected do
			if p == c or p:IsDescendantOf(c) then return true end
		end
		return false
	end
	local function isFoundation(c) return c.Name:sub(1, 10) == "Foundation" end
	local KEEP_HIDDEN = {
		RobloxGui = true,
		InGameFullscreenTitleBarScreen = true,
		_FullscreenTestGui = true,
		_DeviceTestGui = true,
	}
	local function keepTop(c)
		return KEEP_HIDDEN[c.Name] or isFoundation(c) or holdsPage(c)
	end
	local function safeClearCoreGui()
		for _, c in ipairs(CoreGui:GetChildren()) do
			if not keepTop(c) then
				pcall(c.Destroy, c)
			elseif c:IsA("LayerCollector") then
				local show = holdsPage(c) or isFoundation(c)
				pcall(function() if c.Enabled ~= show then c.Enabled = show end end)
			end
		end
	end
	if getgenv then
		getgenv().safeClearCoreGui = safeClearCoreGui
		if not getgenv().__banClearGuard and hookmetamethod and getnamecallmethod then
			getgenv().__banClearGuard = true
			local wrap = newcclosure or function(f) return f end
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
				local m = getnamecallmethod()
				if (m == "ClearAllChildren" or m == "clearAllChildren")
					and typeof(self) == "Instance" and self.ClassName == "CoreGui" then
					return getgenv().safeClearCoreGui()
				end
				return oldNamecall(self, ...)
			end))
		end
	end
	safeClearCoreGui()
	log("CoreGui cleared (page kept)")
	local lockConns = {}
	table.insert(lockConns, CoreGui.ChildAdded:Connect(function(c)
		task.defer(function()
			if c.Parent == CoreGui and not keepTop(c) then
				log("removed new CoreGui screen:", c.Name)
				pcall(c.Destroy, c)
			end
		end)
	end))
	local CAS = game:GetService("ContextActionService")
	local blockedKeys = {
		Enum.KeyCode.Escape, Enum.KeyCode.ButtonStart, Enum.KeyCode.ButtonSelect,
		Enum.KeyCode.F1, Enum.KeyCode.F2, Enum.KeyCode.F3, Enum.KeyCode.F4,
		Enum.KeyCode.F5, Enum.KeyCode.F6, Enum.KeyCode.F7, Enum.KeyCode.F8,
		Enum.KeyCode.F9, Enum.KeyCode.F10, Enum.KeyCode.F11, Enum.KeyCode.F12,
	}
	local function sink() return Enum.ContextActionResult.Sink end
	if not pcall(CAS.BindCoreActionAtPriority, CAS, "BanPageLockdown", sink, false, 100000, table.unpack(blockedKeys)) then
		pcall(CAS.BindActionAtPriority, CAS, "BanPageLockdown", sink, false, 100000, table.unpack(blockedKeys))
	end
	local GameSettings = UserSettings().GameSettings
	table.insert(lockConns, game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			if StarterGui:GetCore("DevConsoleVisible") then StarterGui:SetCore("DevConsoleVisible", false) end
		end)
		pcall(function()
			if GameSettings.PerformanceStatsVisible then GameSettings.PerformanceStatsVisible = false end
		end)
		for _, c in CoreGui:GetChildren() do
			if c:IsA("LayerCollector") and c.Enabled and not holdsPage(c) and not isFoundation(c) then
				pcall(function() c.Enabled = false end)
			end
		end
	end))
	log("lockdown active")
	local clickConn = UIS.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local pos = input.Position
		local names = {}
		pcall(function()
			for i, obj in game:GetService("CoreGui"):GetGuiObjectsAtPosition(pos.X, pos.Y) do
				if i > 5 then break end
				table.insert(names, obj:GetFullName())
			end
		end)
		log(("click at %d,%d processed=%s mouse=%s top=[%s]"):format(pos.X, pos.Y, tostring(processed),
			tostring(UIS.MouseBehavior), table.concat(names, " | ")))
	end)

	local keyConn
	closePreview = function()
		if keyConn then keyConn:Disconnect() keyConn = nil end
		mouseConn:Disconnect()
		clickConn:Disconnect()
		for _, c in lockConns do c:Disconnect() end
		pcall(CAS.UnbindCoreAction, CAS, "BanPageLockdown")
		pcall(CAS.UnbindAction, CAS, "BanPageLockdown")
		pcall(function() root:unmount() end)
		gui:Destroy()
		modalGui:Destroy()
		pcall(function() UIS.MouseBehavior = mouseWas.behavior end)
		pcall(function() UIS.MouseIconEnabled = mouseWas.icon end)
		for t, on in coreStates do pcall(StarterGui.SetCoreGuiEnabled, StarterGui, t, on) end
		closePreview = nil
	end
    --[[
	keyConn = UIS.InputBegan:Connect(function(input)
		if input.KeyCode == CONFIG.closeKey and closePreview then closePreview() end
	end)
    ]]--
end)
if not ok then log("SCRIPT ERROR:", err) end