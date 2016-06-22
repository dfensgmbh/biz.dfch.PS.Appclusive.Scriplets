select * from core.Node where Name = 'Test3';
select * from core.ExternalNode where NodeId = 635;
select * from core.ExternalNodeBag where ExternaldNodeId = 147

-- Node job
select * from core.Job where EntityKindId = 1 and RefId = 635
-- Worker job
--select * from core.Job where ParentId = 1504
-- order item job
select * from core.Job where Id = 1502
-- order item
select * from core.OrderItem where Id = 165
-- order job
select * from core.Job where Id = 1501
-- order
select * from core.[Order] where Id = 165
-- approval job
select * from core.Job where EntityKindId = 5 and parentId = 1501
-- approval
select * from core.Approval where Id = 165